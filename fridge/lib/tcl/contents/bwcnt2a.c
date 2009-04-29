#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define MAXCONNS 30
#define TFRM 1
#define TCP 2

main(int argc, char **argv)
{
  int conns=0, i, j, cnum;
  int src, dst, size, dummy1, dummy4, pid;
  float ts, tsmax=0.0, psrc, pdst, tdiff;
  char type[10], flags[10];
  char line[80];
  char event;
  int *tn, connspace;
  float *srcs;
  float *dsts;
  int *counts;
  int *types;
  int tcpconns=0;
  int tfrmconns=0;
  int starttime=285;
  int lsrc, ldst, bw;
  double bwf=2.0;
  FILE *file;

  if (argc<5) {
    fprintf(stderr, "Usage: bwvt <avlen> <src> <dst> <filename>\n");
    exit(0);
  }
  file = fopen(argv[4], "r");
  if (file==NULL) {
    fprintf(stderr, "bwvt: failed to open file %s\n", argv[4]);
    exit(0);
  }
  lsrc=atoi(argv[2]);
  ldst=atoi(argv[3]);
  bwf=atof(argv[1])*1000000.0/8.0;
  srcs=(float*)malloc(sizeof(float)*MAXCONNS);
  dsts=(float*)malloc(sizeof(float)*MAXCONNS);
  counts=(int*)malloc(sizeof(int)*MAXCONNS);
  types=(int*)malloc(sizeof(int)*MAXCONNS);
  connspace=MAXCONNS;
  //pass 1
  while(feof(file)==0) {
    fgets(line, 80, file);
    sscanf(line, "%c %f %d %d %s %d %s %d %f %f %d %d",
	   &event, &ts, &src, &dst, type, &size, flags, &dummy1, &psrc, 
	   &pdst, &dummy4, &pid);
    //only trace the packets on link lsrc -> ldst when they enter the queue
    //and only trace data packets in that direction
    if ((src!=lsrc)||(dst!=ldst)||(dummy1==1)) continue;

    //find the connection number
    cnum=-1;
    for(i=0;i<conns;i++) {
//      printf("%d srcs: %f,%f  %f,%f\n", i, srcs[i], dsts[i], pdst, psrc);
      if ((srcs[i]==psrc)&&(dsts[i]==pdst)) {
	cnum=i;
	break;
      }
    }
    if ((event=='+')&&(cnum==-1)) {
      fprintf(stderr, "new connection %d from %f to %f\n", conns, psrc, pdst);
      srcs[conns]=psrc;
      dsts[conns]=pdst;
      counts[conns]=0;
      if (strcmp(type, "tcp")==0) {
	tcpconns++;
	types[conns]=TCP;
      } else if (strcmp(type, "tcpFriend")==0 || strcmp(type, "message")==0) {
	tfrmconns++;
	types[conns]=TFRM;
      }
      cnum=conns;
      conns++;
      if(conns==connspace) {
	srcs=(float *)realloc(srcs, sizeof(float)*(conns+MAXCONNS));
	dsts=(float *)realloc(dsts, sizeof(float)*(conns+MAXCONNS));
	counts=(int *)realloc(counts, sizeof(int)*(conns+MAXCONNS));
	types=(int *)realloc(types, sizeof(int)*(conns+MAXCONNS));
	connspace=conns+MAXCONNS;
      }
    }
    if (event=='r') {
      if (ts>starttime)
	counts[cnum]+=size;
      tsmax=ts;
    }
  }
  fprintf(stderr, "writing output\n");
  //printf("\"tcp\"\n");
  for(j=0;j<tcpconns;j++) {
    int max;
    int maxval;
    max=0;maxval=0;
    for(i=0;i<conns;i++) {
      if (types[i]==TCP)
	if (counts[i]>maxval) {
	  max=i;
	  maxval=counts[i];
	}
    }
    // The first number is the number of tcp connections, jittered
    // The second number is  ?/link bandwidth in bytes
    // bwf: link bandwidth in Bps
    // tsmax: ending time
    // conns: number of active connections of class 0
    // counts[max]:
    printf("tcp %f %f\n", tcpconns+((random()&255)/256.0)-0.5, counts[max]*conns/(bwf*(tsmax-starttime)));
    counts[max]=0;
  }
//  printf("\n\"tfrm\"\n");
  for(j=0;j<tfrmconns;j++) {
    int max;
    int maxval;
    max=0;maxval=0;
    for(i=0;i<conns;i++) {
      if (types[i]==TFRM)
	if (counts[i]>maxval) {
	  max=i;
	  maxval=counts[i];
	}
    }
    printf("tfrm %f %f\n", tfrmconns+((random()&255)/256.0)-0.5, counts[max]*conns/(bwf*(tsmax-starttime)));
//    printf("conns: %d\n", conns);
    counts[max]=0;
  }
}

#.h1 Shell Statistical Spam Filter and Whitelist
#.h2 About
#.h3 Author
#.P
#Steven Hauser.
#.H3 Origin
#.P
#.URL http://www.tc.umn.edu/~hause011/article/Statistical_spam_filter.html http://www.tc.umn.edu/~hause011/article/Statistical_spam_filter.html
#.h2 Client Side Unix Shell - AWK with updating email address "Whitelist"
#.P
#I now use a "Statistical Spam Filter". Wow, the scummy sewer
#of internet mail is cleansed, refreshed and usable again.
#Just using the delete button was getting too difficult, I got 8 to
#10 spam for every good piece of mail. As a spam detector I am
#not as good a filter as you might think, just the subject and address
#is not always enough, an anti-spam tool I am not, 
#I would occasionally open a spam to my great annoyance.
#
#.h2 My interpretation of Paul Graham's Spam Article
#.P
#My filter was inspired by Paul Graham's article about a 
#Naive Bayesian spam filter. The article is at 
#<a href="http://www.paulgraham.com/spam.html">"A Plan for Spam".</a>  
#He basically says that you get statistics on how often tokens show
#up in two bodies of mail, (spam and good,) and then calculate the 
#a statistical value that a single mail is spam by looking at the tokens in it. 
#The more mail in the good and spam mail bodies, the better the 
#filter is "trained".  Jeez, he made it sound so easy. And it is.
#I slapped an anti-spam tool together as a ksh and awk script 
#for use as a personal filter on a Unix type system.  To implement it 
#I put it in the  
#~/.forward file. The code is at the bottom of the article, less than 100
#lines for the training script and less than 100 lines for the filter.
#The total code for the filter and training script is less than 200 
#lines, including comments, and it is less than 6000 characters. 
#.P
#This filter differs in lots of ways from the Paul Graham article.
#I took out some of the biases he describes and simplified it, 
#maybe it is too simple.  What I find most interesting is that 
#the differences do not seem to matter much, I still filter out 96+% of spams.
#I got those results with a spam sample that is at least 
#500 emails and a good email sample that is at least 700 emails.  
#With smaller training samples or a different mail mix it 
#may not get as good results, or it may be better.
#Note: I later changed the training body to be more like the proportion of
#real spam to good mail, which is much more spam than good mail, about
#8-10 spam to every good mail received and the anti-spam tool worked better.
#.h2 How the Spam Filter Works in Unix
#.P
#First I run the training script on two bodies of mail, ~/Mail/received 
#(good mail) and ~/Mail/junk (saved spam mail.) The ~/Mail/received file is 
#already created on my unix box and holds mail that I have read and
#not deleted.  The training script finds all the tokens in the 
#emails and gives them a probability depending on how the token
#is found in the "spam mail" and the "good mail". The training script
#also creates the whitelist of addresses from the "good mail." As the
#mail flows through the system the training script will then "learn"
#each time it is run.
#
#.P
#I run the actual spam filter script from the .forward file which
#allows a user to process mail before it hits your inbox.  
#(Look up "man forward" at the shell prompt for further information 
#on the .forward file.) The script first checks the whitelist for a 
#good address, if it is found it passes the filter. If the address is 
#not found it is passed to the statistical spam filter, the tokens 
#are checked and the email is given a spaminess value. Above a 
#certain value the email is classified as spam and put in the ~/Mail/junk
#file, below the value it passes to /var/spool/mail/mylogin where
#I read it as god intended email to be read, with a creaky old unix client.
#However, I can still read it with any other client I want, POP or IMAP.
#
#.h2 Testing the Spam Filter
#.P
#I included a little test script below that I used to check my results.
#I just split emails into files and run them one at a time
#and check the value the filter gives.
#.P
#Testing on email that has been used to train the filter will 
#give results that are very good and not valid, so I tested on email
#not seen by the training script. The filter does get much better at 
#filtering as the training sample gets bigger, just like the other 
#statistical spam filters.  For example, at lower sample sizes (trained 
#with 209 good mails, 301 spammails) the filter was pretty bad. When 
#the average spam value cutoff was raised to .51 so no good mail was blocked,
#44% of the spam email passed through on a set of 320 spam and 
#683 good email.  Even so, that means %56 of the spam was blocked.
#Small sample sizes are not perfect, but are usable 
#and I began using the mail filter with a sample set of about 
#600 good mail and 300 spam.  As the training sample increased the results 
#improved. As I changed the mail mix to reflect the real spam proportions
#it got even better, around 96-98% of the spam blocked. I think the lower
#early results were because of the proportions of spam to good email, they
#should reflect the real proportion received on the system used by 
#the filter.
#.P
#Paul Graham or others may have superior filters and better mathematics
#for anti-spam algorithms but I am not 
#sure that it matters all that much, the amount of spam that 
#gets through is small enough not to bother me. 
#.h2 Filter Performance
#.P
#I used gawk in the filter and checked it with the gawk profiler to
#look for performance problems. The largest performance constraint is 
#creating the spam-probability associative array in memory, the key-value
#pairs of tokens and the spam value I assign to them. Creating this
#associative array is more that 95% of the current time to process an
#email through the filter and gets worse when the set of tokens gets larger.
#Perl and other language users can get around this performance
#problem with DBM file interfaces, currently not available to my gawk filter.
#
#.h3 White List Filter Improves Performance and Cuts Errors
#.P
#I added a "whitelist" of good email addresses, a feature
#that helps keep good email from a bad classification and improves 
#performance by a huge amount (at least a magnitude of 100) by not 
#having to further filter the message. 
#The white list is not one of the "challenge-response" things that annoys me
#so much that I toss any such email away, it simply learns from the email 
#used to train the filter, it saves addresses that are from email that 
#has passed the filter and gets in my "received" file. I figure that
#if I receive a good email from someone, chances are 100% that I want
#to receive email from that address. Note there is a place in the white 
#list script to get rid of commonly forged email 
#addresses, like your own address. 
#
#.h2 Why Differences With Bayes Filters Do Not Matter
#
#.P
#The main concept put forward by Paul Graham holds
#true and seems ungodly robust: applying statistics to filter 
#spam works very well compared to lame rule sets and black lists. 
#My program just proves the robustness of the solution; apparently 
#any half-baked formula (like what I used) seems to work as long
#as the base probability of the tokens is computed.
#.P
#Here are some of the many differences between this filter
#and the filter in the Paul Graham article in no particular
#order of importance:
#.UL
#.LI
#  I do not lower-case the tokens, one result is that token
#   frequency is set to three instead of five to be included in
#   in the spam-probability associative array. I think that 
#   "case" is an important token characteristic.
#.LI
#  "Number of mails" is replaced with "number of tokens."
#   My explanation is that I am looking at a token frequency 
#   in an interval of a stream of tokens.  It seems simpler to
#   think of it that way, instead of number of mails. 
#   And when I tried "number of mails" I got the same result 
#   values on the messages for the formula I used.
#.LI
#  "Interesting tokens" were tokens in the message with a spam 
#   statistic "greater than 0.95" and "less than 0.05"  
#   Easy to implement. I did not figure out the fifteen most 
#   interesting tokens, the limit used by Paul Graham. As a result, 
#   most of my mail has more than 15 interesting tokens, a few
#   have fewer, which could be a weakness, but does not seem to matter
#   too much.
#.LI
#  Paul Graham's Naive Bayesian formula goes to 0 or 1
#   pretty quickly, which is fine, I tried it out in awk too.
#   But now I just sum the "interesting token" probabilities and 
#   divide by the number of "interesting tokens" per message.  
#   Yes, it is just an average of the probability of "interesting tokens"  
#   and it is easy to implement and spreads the values over a 0-1 
#   interval, spam towards 1 and good mail towards 0.
#   I did this to implement some spam filtering as soon as possible. Even
#   with a small sample of mail I was able to adjust the average 
#   probability value up to keep all the good mail and still get rid of 
#   a good proportion of spam. As I acquired more sample mail the 
#   filter caught more spam and I adjusted the average probability 
#   value down.
#.LI
#  I have a "training" program that generates the token probabilities
#   and an address "whitelist" to be run as a batch job at intervals 
#   (like once a day or week) and a separate filter program run out 
#   of ".forward"  
#.LI
#  I did not double the frequency value of the "good tokens" to bias
#   them in the base spam probability calculation of each token.
#.LI
#  Tokens not seen by the filter before are ignored.
#   Paul Graham gives them a 0.4 probability of spaminess.
#   Most other methods of calculating the probability of unknown 
#   tokens end up being ignored by my formula as they would have 
#   a probability outside the "interesting token" ranges.
#.LI
#  I noticed that Paul Graham ignores HTML comments. When I looked at
#   some of the spam I found out why, some spammers load recipient 
#   address and common words into HTML comments spread through the
#   text to pass rule filters but the statistical spam filter 
#   seems to find them anyway so I include tags, comments, everything.
#./UL
#.H2 Code
#.h3 Test SpamFilter
#.P
#Note: Do not test mail that has been used to train the filter,
#       test mail not seen by the training program.
#.PRE
##!/bin/ksh
filter_test () {
  # Split a file of unix email into many mail files with this:
  cat ~/Mail/rece* |csplit -k -f good -n 4 - '/^From /' {900}

  # Run a modified filter that displays the spam value for each mail file.
  # I just commented out the last part of the filter and added a 
  # print statement of the Subject line and spam value the filter found.
  for I in test/good*
  do
     cat $I | [filter_program-that_shows_the_value_only]
  done | sort -n 
}
#./PRE
#.H3  Train SpamFilter.
#.P
#Call from the command line or in a crontab file.
#.PRE
##!/bin/ksh
number_of_tokens (){
  zcat $1 | cat $2 - | wc -w
}

 # Note: Get rid of addresses that are commonly forged at the
 #       "My-Own-Address" string.
address_white_list (){
  zcat $1 | 
  cat $2 - | 
  egrep '^From |^Return-Path: ' | 
  nawk '{print tolower($2)}'| 
  nawk '{gsub ("<",""); gsub (">","");print;}'| 
  grep -v 'My-Own-Address'| 
  sort -u > ~/Mail/address_whitelist
}

 # Create a hash with probability of spaminess per token.
 #       Words only in good hash get .01, words only in spam hash get .99
spaminess () {
nawk 'BEGIN {goodnum=ENVIRON["GOODNUM"]; junknum=ENVIRON["JUNKNUM"];}
       FILENAME ~ "spamwordfrequency" {bad_hash[$1]=$2}
       FILENAME ~ "goodwordfrequency" {good_hash[$1]=$2}

    END    {
    for (word in good_hash) {
        if (word in bad_hash) { print word, 
            (bad_hash[word]/junknum)/ \
            ((good_hash[word]/goodnum)+(bad_hash[word]/junknum)) }
        else { print word, "0.01"}
    }
    for (word in bad_hash) {
        if (word in good_hash) { done="already"}
        else { print word, "0.99"}
    }}' ~/Mail/spamwordfrequency ~/Mail/goodwordfrequency 

}

 # Print list of word frequencies
frequency (){
  nawk ' { for (i = 1; i <= NF; i++)
        freq[$i]++ }
    END    {
    for (word in freq){
        if (freq[word] > 2) {
          printf "%s\t%d\n", word, freq[word];
        }
    } 
  }'
}
 # Note: I store the email in compressed files to keep my storage space small,
 #       so I have the gzipped mail that I run through the filter training 
 #       script as well as current uncompressed "good" and spam files.
 #       
prepare_data () {
  export JUNKNUM=$(number_of_tokens '/Your/home/Mail/*junk*.gz' '/Your/home/Mail/junk')
  export GOODNUM=$(number_of_tokens '/Your/home/Mail/*received*.gz' '/Your/home//Mail/received')
  address_white_list '/Your/home/Mail/*received*.gz' '/Your/home/Mail/received'

  echo $JUNKNUM $GOODNUM

  zcat ~/Mail/*junk*.gz | cat ~/Mail/junk - |
    frequency|
    sort -nr -k 2,2 > ~/Mail/spamwordfrequency
  zcat ~/Mail/*received*.gz | cat ~/Mail/received - |
    frequency|
    sort -nr -k 2,2 > ~/Mail/goodwordfrequency

  spaminess| 
    sort -nr -k 2,2 > ~/Mail/spamprobability
  # Clean up files
  rm ~/Mail/spamwordfrequency ~/Mail/goodwordfrequency 
}

 #########
 # Main

prepare_data
exit
#./PRE
#.H3 Spamfilter using statistical filtering.
#.P
#Inspired by the Paul Graham article "A Plan for Spam" www.paulgraham.com
#.P
#Implement in the .forward file like so:
#.PRE
#"| /Your/path/to/bin/spamfilter"
#./PRE
#.P 
#If mail is spam then put in a spam file
#else put in the good mail file. 
#.PRE
##!/bin/ksh
spamly () {
/usr/bin/nawk '

   { message[k++]=$0; }

   END { if (k==0) {exit;} # empty message or was in the whitelist.

         good_mail_file="/usr/spool/mail/your_user";
         spam_mail_file="/Your/home/Mail/junk";
         spam_probability_file="/Your/home/Mail/spamprobability";
         total_tokens=0.01;

         while (getline < spam_probability_file)
            bad_hash[$1]=$2; close(spam_probability_file);

         for (line in message){ 
           token_number=split(message[line],tokens);
           for (i = 0; i <= token_number; i++){
             if (tokens[i] in bad_hash) { 
               if (bad_hash[tokens[i]] <= 0.06 || bad_hash[tokens[i]] >= 0.94){
                  total_tokens+=1;
                  spamtotal+=bad_hash[tokens[i]];
                }
              }
            }
         }

         if (spamtotal/total_tokens > 0.50) { 
            for (j = 0; j <= k; j++){ print message[j] >> spam_mail_file}
            print "\n\n" >> spam_mail_file;
         }
         else {
            for (j = 0; j <= k; j++){ print message[j] >> good_mail_file}
            print "\n\n" >> good_mail_file;
         }
   }'
}

 # Check whitelist for good address. 
 # if in whitelist then put in good_mail_file
 #   else Pass message through filter.
whitelister () {
  /usr/bin/nawk '
      BEGIN { whitelist_file="/Your/home/Mail/address_whitelist";
              good_mail_file="/usr/spool/mail/your_user";
              found="no";
              while (getline < whitelist_file)
              whitelist[$1]="address"; close(whitelist_file);
      }
      { message[k++]=$0;}
      /^From / {sender=tolower($2); 
            gsub ("\<","",sender);
            gsub ("\>","",sender); 
            if (whitelist[sender]) { found="yes";}
      }
      /^Return-Path: / {sender=tolower($2); 
            gsub ("\<","",sender);
            gsub ("\>","",sender); 
            if (whitelist[sender]) { found="yes";}
      }
      END { if (found=="yes") { 
               for (j = 0; j <= k; j++){ print message[j] >> good_mail_file}
               print "\n\n" >> good_mail_file;
            }
            else {
               for (j = 0; j <= k; j++){ print message[j];}
            }
      }'
}

 #####################################
 # Main
 # The mail is first checked by the white list, if it is not found in the
 # white list it is piped to the spam filter.
whitelister | spamly 
exit
#./PRE

// fsm.h
// $Revision: 1.5 $
//
// ======================================================================
// Copyright 2008 Wm Miller
//
// This file is part of fsm-gen, and is distributed under the terms of the
// GNU Lesser General Public License .
//
// Copies of the GNU General Public License and the GNU Lesser General Public
// License are included with this distrubution in the files COPYING and
// COPYING.LESSER, respectively.
//
// Fsm-gen is free software: you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
// 
// Fsm-gen is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
// more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with fsm-gen.  If not, see <http://www.gnu.org/licenses/>.
//
// The author may be contacted at wmmsf at users.sourceforge.net.
// ======================================================================
//


#include <stdbool.h>
#include <malloc.h>
#include <stdint.h>

#ifndef _FSM_H
#define _FSM_H

typedef uint16_t event_t;
typedef uint16_t state_t;


// structure of fsm transition information 
//      a fsm with, say, 5 states and 3 events will have 15 of these
//  if you're at all interested in speed, keep this struct size a
//      power of 2.
struct fsm_s {
    bool        (*action)(void);
    uint16_t    newstate_true;          // next state if action returns true
    uint16_t    newstate_false;         // next state if action returns false
};

// struct for recording fsm transitions (for debug)
struct fsm_trace_s {
    event_t     event;  // got this event and
    state_t     state;  // went to this state
};

#define FSM_MAXTRACE 8

// context for each fsm
typedef struct fsm_s (*fsm_aap)[1][1];  // ptr to whole doubly ss'd array
typedef struct fsm_s fsm_aa[1][1];      // doubly ss'd array
struct fsmContext_s {
    fsm_aap         fsmp;
    state_t         currentState;
    state_t         maxstate;
    event_t         maxevent;

    bool            traceEnable;
    unsigned int    traceIndex;
    struct fsm_trace_s trace[FSM_MAXTRACE];
};

// array of contexts
#define FSM_MAXCONTEXTS 10
extern struct fsmContext_s fsmContexts[];
extern bool fsm_invalid_event(void);


// call this fcn to instantiate a context
extern unsigned int fsm_allocFsm(struct fsm_s (*)[], state_t,
                                            unsigned int, unsigned int);

// this is the fcn to call to make the fsm transition
extern unsigned int fsm(unsigned int handle, event_t event);

// call this once at startup
extern unsigned int    fsminit(void);

#endif /* _FSM_H */

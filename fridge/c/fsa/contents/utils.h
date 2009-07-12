// utils.h
// $Revision: 1.2 $
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
// ======================================================================
//

#ifndef _UTILS_H
#define _UTILS_H

#include <stdio.h>
#include <stdlib.h>

#define WARN_IF(EXP) \
 do { if (EXP) \
         fprintf (stderr, "Warning: " #EXP "\n"); } \
 while (0)


#define EXIT_IF(EXP,RET) \
    do { if (EXP) { \
        fprintf (stderr, "Warning: " #EXP "\n"); puts("exiting...");exit(RET);}} \
    while (0)

#define RET_IF(EXP,RET) \
    do { if (EXP) { \
        fprintf (stderr, "Warning: " #EXP "\n"); puts("returning...");return(RET);}} \
    while (0)

// errors
// TODO: move these defs to errors.h or somesuch
/*
#define ERR_SUCCESS 0
#define ERR_FAIL    100

// fsm and related
#define FSM_NOCTX       201
#define FSM_UNKSTATE    202
#define FSM_UNKEVENT    202
*/

typedef unsigned int xxxErrors;
enum xxxErrors {
ERR_SUCCESS = 0,
ERR_FAIL    = 100,

// fsm and related
FSM_BASEERR     = 200,
FSM_NOCTX,
FSM_UNKSTATE,
FSM_UNKEVENT   
};

// return number of elements in a 1-dim'l array
#define NUMBEROFELEMENTSIN(arrayname) (sizeof(arrayname)/sizeof(arrayname[0]))

#endif /* _UTILS_H */

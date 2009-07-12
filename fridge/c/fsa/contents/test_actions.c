// test_actions.c
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
// The author may be contacted at wmmsf at users.sourceforge.net.
// ======================================================================
//
// this file is included to build the sample code only.
// it contains a very simple action function for each transition
// specified in the sample fsm spec file, test.fsm.
//


#include "stdbool.h"
#include "stdio.h"

bool fsm_s1_a(void) {
    printf("called fsm_s1_a ----> ");
    return true;
}

bool fsm_s1_b(void) {
    printf("called fsm_s1_b ----> ");
    return true;
}

bool fsm_s2_a(void) {
    printf("called fsm_s2_a ----> ");
    return true;
}

bool fsm_s2_b(void) {
    printf("called fsm_s2_b ----> ");
    return true;
}

bool fsm_s2_ab(void) {
    printf("called fsm_s2_ab ----> ");
    return true;
}

bool fsm_s2_d(void) {
    printf("called fsm_s2_d ----> ");
    return true;
}

bool fsm_s3_def(void) {
    printf("called fsm_s3_def ----> ");
    return true;
}




#!/bin/bash

################################################################################
# CLEANUP
################################################################################

echo -n -e "\033[1;33m CLEANING UP TEMPORATY FILES... \033[0m"
make -s clean
echo -e "\033[1;32mDone!\033[0m"

################################################################################
# SIMULATE: repo_integrity
################################################################################

make simulate TOP=repo_integrity CONFIG=default

################################################################################
# COLLECT & PRINT
################################################################################

clear
make print_logo

rm -rf temp_ci_issues
touch temp_ci_issues

grep -s -r "\[1;31m\[FAIL\]" ./log | sed "s/.*\.log://g" >> temp_ci_issues
grep -s -r "ERROR:" ./log | sed "s/.*\.log://g" >> temp_ci_issues

echo -e "\n\n"
echo -e "\033[1;36m___________________________ CI REPORT ___________________________\033[0m"
grep -s -r "\[1;32m\[PASS\]" ./log | sed "s/.*\.log://g"
grep -s -r "\[1;31m\[FAIL\]" ./log | sed "s/.*\.log://g"
grep -s -r "WARNING:" ./log | sed "s/.*\.log://g"
grep -s -r "ERROR:" ./log | sed "s/.*\.log://g"

echo -e "\n\n"
echo -e "\033[1;36m____________________________ SUMMART ____________________________\033[0m"
echo -n "PASS    : "
grep -s -r "\[1;32m\[PASS\]" ./log | sed "s/.*\.log://g" | wc -l
echo -n "FAIL    : "
grep -s -r "\[1;31m\[FAIL\]" ./log | sed "s/.*\.log://g" | wc -l
echo -n "WARNING : "
grep -s -r "WARNING:" ./log | sed "s/.*\.log://g" | wc -l
echo -n "ERROR   : "
grep -s -r "ERROR:" ./log | sed "s/.*\.log://g" | wc -l
echo -e "\n\n"

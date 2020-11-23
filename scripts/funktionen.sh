#!/bin/bash
# Autor: I. Kuss, hbz
# eine Funktionssammlung für bash-Skipte

# allgemeiner Kram, Zeichenkettenverarbeitung

# Funktionsdefinitionen
function stripOffQuotes {
  local string=$1;
  local len=${#string};
  echo ${string:1:$len-2};
}

func2() {
  echo "Starting func2"
  }

#!/bin/bash

wget $(wget -O- "$1" | sed -n 's/<a href="\(.*\.pdf\)" class="c-pdf-download__link".*/\1/p' | head -n 1) -O "${2:-${1##*/}.pdf}"
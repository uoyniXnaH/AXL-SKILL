# AXL-SKILL

My SKILL programs repository for Cadence Allegro.

Please note that all programs are based on/developed for Allegro 16.6


# BRIEF INTRO

The Cadence SKILL is used to customize your design environment of Cadence Allegro, it is based on Lisp and supports a more conventional C-like syntax.

For more infomation, just refer to _sklanguser.pdf_ by Cadence.


# ABOUT THIS REPOSITORY

Every program here is supposed to achieve certain function, or play as a module. None of them are interdependent. In addition, programs here are written for universal use, namely that (generally) they won't be restricted by specific design rules, criteria, etc.

And please note that some programs remain incompleted, because I'm lazy.


# CONTENTS

* [auto drill legend](#auto_drill_legend)
* [class map](#class_map)
* [dvia](#dvia)
* [package_out](#package_out)
* [pad count](#pad_count)
* [padline](#padline)
* [rpd](#rpd)
* [same_via](#same_via)
* [setGrid](#setGrid)
* [short seg](#short_seg)
* [short_skill](#short_skill)
* [sldv](#sldv)
* [wid](#wid)

## auto_drill_legend
Complete the drill legend automatically. The characters of drills are alphabetically ordered, and figures are all cross(20x20).

## class_map
This is a module that create a form with current class/subclass table. The color and vis-status are also real-time and changeable. Generally its function is close to one in the options bar. Cadence SKILL supports mapping class/subclass at the options bar, however form can not be utilized with such function, this module is developed for this.
  
## dvia
Delete GND via by select.
  
## package_out
Export psm/dra/pad of selected symbols. Allegro can only export the whole library of a PCB file, this program is used as an complement.
  
## pad_count
Count the amount of pads in a PCB file. Somtimes it may be useful.

## padline
Change the width of linesegs to avoid exceeding connecting pins. This program is incompleted as it can be used only when a lineseg with enough length is connected to the pin vertically or horizontally. Well I do have considered the alogrithm for some more general conditions, but they are so complex that I suppose it's unwise to spend time as it's not an important work for me temporarily. Perhaps it won't be completed.

## rpd
Calculate length of lines in a match group with pin/via/stripe compensation. The outcome is static and it should be updated manually. (So far Cadence SKILL does not support dynamic triggers/events, except for certain operations.)

## same_via
Highlight same type vias. This skill is out-of-date since allegro supports such function initially.

## setGrid

## short_seg

## short_skill

## sldv

## wid



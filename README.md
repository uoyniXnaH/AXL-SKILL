This repository will not be updated anymore.
2017/10/9

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
* [cellular automaton](#cellular_automaton)
* [class map](#class_map)
* [dvia](#dvia)
* [fc](#fc)
* [gvia](#gvia)
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
To complete the drill legend automatically. The characters of drills are alphabetically ordered, and figures are all cross(20x20).

## cellular_automaton
As its name, a program of cellular automaton. This program is just for fun, no practical use in Allegro. It is a prototype that will execute automatically and stop after be saved(to set such a trigger is easy). The program will become slow when there are too much cells, because axlDeleteObject is slow.

## class_map
This is a module that create a form with current class/subclass table. The color and vis-status are also real-time and changeable. Generally its function is close to one in the options bar. Cadence SKILL supports mapping class/subclass at the options bar, however form can not be utilized with such function, this module is developed for this.
  
## dvia
To delete GND via by select.

## fc
To modify pin's dynamic contacting type into FULL_CONTACT by selecting. This skill does not disable dynamic shape fill.
  
## gvia
To change via net to GND by select.

## package_out
To export psm/dra/pad of selected symbols. Allegro can only export the whole library of a PCB file, this program is used as a complement.
  
## pad_count
To count the amount of pads in a PCB file. This program is out-of-date since you can find the amount in the Summary Drawing Report, or you can count pins manually by select all of them.

## padline
To change the width of linesegs to avoid exceeding connecting pins. This program is incompleted as it can be used only when a lineseg with enough length is connected to the pin vertically or horizontally. Well I do have considered the alogrithm for some more general conditions, but they are so complex that I suppose it's unwise to spend time as it's not an important work for me temporarily. Perhaps it won't be completed.

## rpd
To calculate length of nets in a match group with pins/vias/strips compensation. The outcome is static and it should be updated manually. (So far Cadence SKILL does not support dynamic triggers/events, except for certain operations.)

## same_via
To highlight same type vias. This skill program is out-of-date since allegro supports such function initially.

## setGrid
To modify grid settings. Both Etch and Non-etch grids will be modified. Note that this program is non-interactive, which means you can execute it freely during an interactive command.

## short_seg
To find short linesegs in the board. Segments length can be defined (default is 2 mils), and segments close to vias and pins will be ignored.

## short_skill
A collection of some short skills, they are short but useful.

## sldv
To find if there are vias without soldermask on both layers. Misreports do exist thanks to Allegro's annoying selecting mechanism.

## wid
To highlight/modify specific width of clines. Sometimes it is neccessary to confirm if there are elements out of process capability, such as clines with too thin width. With this program, you can find, highlight clines with specific width (>, < or =), and change their width by one click.


;;; Lepton EDA netlister
;;; lepton-netlist back end for KiCad PCB Editor
;;; Copyright (C) 2022 John P. Doty
;;;
;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

; Export a design to KiCad PCB Editor

(use-modules (netlist schematic)
             (netlist schematic toplevel)
	     (ice-9 pretty-print))

	     
; A KiCad netlist looks like a long S-expression. 
; However, it seems that the first line must be literally '(export (version "E")'
; So, handle the subexpressions as S-expressions, but
; bracket them with literal strings	     

(define (kicad output-filename)
	(format #t "~A\n" "(export (version \"E\")")
	(pretty-print (components))
	(pretty-print (nets))
	(format #t "~A\n" ")")
)

; What's version "E"? Who knows...

(define (version) (list 'version "E"))


(define (components)
	(cons
		'components
		(map make-comp (schematic-package-names (toplevel-schematic)))
	)
)

(define (make-comp package)
	(list
		'comp
		(list 'ref package)
		(list 'value (gnetlist:get-package-attribute package "value"))
		(list 'footprint (gnetlist:get-package-attribute package "footprint"))
	)
)

(define (nets) 
	(append
		(cons 
			'nets
			(map make-net 
				(schematic-nets (toplevel-schematic))
			)
		)
	)
)


(define (make-net netname) 
	(append
		(list
			'net
			(make-code)
			(make-name netname)
		)
		(map make-node (get-all-connections netname))
	)
)


(define code-count 0 )

(define (make-code)
	(set! code-count (+ code-count 1))
	(list 'code (number->string code-count))
)

(define (make-name n) (list 'name n))

; For now, give all connection the "passive" type
; Leave out pinfunction, it seems to be optional

(define (make-node connection)
	(list
		'node
		(list 'ref (car connection))
		(list 'pin (cdr connection))
		'(pintype "passive")
	)
)
		



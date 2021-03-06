
(*
abhishek@brixpro:~/parametricity/reflective-paramcoq/test-suite$ ./coqid.sh indFunArg
*)

Require Import SquiggleEq.terms.


Require Import ReflParam.common.
Require Import ReflParam.templateCoqMisc.
Require Import String.
Require Import List.
Require Import Template.Ast.
Require Import SquiggleEq.terms.
Require Import ReflParam.paramDirect ReflParam.indType.
Require Import SquiggleEq.substitution.
Require Import ReflParam.PiTypeR.
Import ListNotations.
Open Scope string_scope.

Require Import ReflParam.PIWNew.

Require Import Template.Template.


(* Inductive nat : Set :=  O : nat | S : forall ns:nat, nat. *)

Run TemplateProgram (genParamIndAll [] "Coq.Init.Datatypes.nat").

Run TemplateProgram (mkIndEnv "indTransEnv" ["Coq.Init.Datatypes.nat"]).
Run TemplateProgram (genWrappers indTransEnv).

(*
Set Printing All.

Run TemplateProgram (genParamIndTotAll [] true "Coq.Init.Datatypes.nat").

Run TemplateProgram (genParamIso [] "Coq.Init.Datatypes.nat").
*)

(* functions wont work until we fully produce the goodness of inductives *)
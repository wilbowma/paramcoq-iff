Require Import ReflParam.common.
Require Import ReflParam.templateCoqMisc.
Require Import String.
Require Import List.
Require Import Template.Ast.
Require Import SquiggleEq.terms.
Require Import ReflParam.paramDirect.
Require Import SquiggleEq.substitution.
Require Import ReflParam.PiTypeR.
Import ListNotations.
Require Import squiggle4.
Open Scope string_scope.

Require Import ReflParam.Trecord.

Inductive Opid : Set :=
| lam
| app
| num (n:nat).

Open Scope nat_scope.

Definition opBindingsLam (o: Opid) : list nat :=
  match o with
  | lam => [1]
  | app => [0;0]
  | num _ => []
  end.

Global Instance sigOpid : GenericTermSig Opid :=
  Build_GenericTermSig _ opBindingsLam.

Require Import SquiggleEq.terms2.
Require Import SquiggleEq.varImplZ.
Require Import SquiggleEq.wftermSet.

Definition V := BinNums.positive.
Definition Tm : Set := (@WTermSet V  Opid _).
Definition BTm : Set := (V*Tm).

Require Import Coq.btauto.Btauto.
Require Import SquiggleEq.LibTactics.

Definition elimTerm (t:Tm) :  tmExt Tm BTm.
Proof.
  destruct t as [t p].
  destruct t as [v | o lbt]; [| destruct o]; simpl in p.
  - exact evar.
  - destruct lbt as [| b lbt]; try inverts p as p.
    destruct b as [lv nt].
    destruct lv as [| v lv]; try inverts p as p.
    destruct lv as [|]; try inverts p as p.
    destruct lbt as [|]; try inverts p as p.
    cases (wft nt) as Ht;[| inverts p].
    exact (@elam Tm BTm (v,(exist _ nt Ht))).
  - destruct lbt as [| b lbt]; try inverts p as p.
    destruct b as [lv f].
    destruct lv as [|]; try inverts p as p.
    destruct lbt as [| b lbt]; try inverts p as p.
    destruct b as [lv a].
    destruct lv as [|]; try inverts p as p.
    destruct lbt as [|]; try inverts p as p.
    cases (wft f) as Hf;[| inverts p].
    cases (wft a) as Ha;[| inverts p].
    exact (@eapp Tm BTm (exist _ f Hf) (exist _ a Ha)).
  - destruct lbt as [|]; try inverts p as p.
    exact (@enum Tm BTm n).
Defined.    


Definition applyBTerm (b:BTm) (u:Tm) :  Tm.
Proof.
  destruct b as (v,t).
  exact (subst_wftset t v u).
Defined.

Require Import SquiggleEq.alphaeq.
Definition Tm_R (t1 t2 :Tm) : Prop:= alpha_eq (proj1_sig t1) (proj1_sig t2).

Definition BTm_R (bt1 bt2 :BTm) : Prop:=
  let (v1, t1) := bt1 in
  let (v2, t2) := bt2 in
  alpha_eq_bterm (bterm [v1] (proj1_sig t1)) (bterm [v2] (proj1_sig t2)).


Require Import squiggle4Thm.

Check obsEqUni.
      
Lemma totalTm_R : TotalHeteroRel Tm_R.
  split;  intros x; exists x; apply alpha_eq_refl.
Defined.

Lemma totalBTm_R : TotalHeteroRel BTm_R.
  split;  intros x; exists x; destruct x; apply alphaeqbt_refl.
Defined.

Lemma elimTerm_R :
   (forall (a1 : Tm) (a2 : Tm),
        Tm_R a1 a2 ->
        Top_squiggle4_tmExt_pmtcty_RR0 Tm Tm Tm_R BTm BTm BTm_R (elimTerm a1) (elimTerm a2)).
Proof using.
  intros ? ? Hr.
  inverts Hr.
  - destruct a1, a2. simpl in *. subst.
    simpl. constructor.
  - destruct a1, a2. simpl in *. subst.
    rename w into p.
    destruct op; simpl.
    + destruct lbt1 as [| b lbt1]. try inverts p as p.
      destruct b as [lv nt].
      destruct lv as [| v lv]; try inverts p as p.
      destruct lv as [|]; try inverts p as p.
      destruct lbt1 as [|]; try inverts p as p.
      simpl in *.
      alphahypsd3.
      simpl. unfold wf_term in p. simpl in p.
      destruct p.
      compute in p.
  
  simpl in Hr.
  simpl.
Check obsEqUni.

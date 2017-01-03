
Notation "a <=> b" := (prod (a->b) (b->a)) (at level 100).

Declare ML Module "paramcoq".


Definition USP 
{A₁ A₂ : Type} (A_R : A₁ -> A₂ -> Type) :Type :=
 forall x y (p1 p2: A_R x y), p1 = p2.

Parametricity Recursive eq.

Lemma eq_R_if : forall
  (A₁ A₂ : Type) (A_R : A₁ -> A₂ -> Type) 
  (A_R_USP : USP A_R)
  (x₁ px₁ : A₁) (x₂ px₂: A₂) 
  (x_R : A_R x₁ x₂) (px_R : A_R px₁ px₂) (p1 : x₁ = px₁) (p2: x₂ = px₂) ,
eq_R A₁ A₂ A_R x₁ x₂ x_R px₁ px₂ px_R p1 p2.
Proof using.
  intros. subst.
  pose proof (A_R_USP _ _ px_R x_R). subst.
  constructor.
Qed.

Parametricity Recursive nat.

Lemma nat_R_eq : forall x y , nat_R x y <=> x = y.
Proof.
  induction x; intros y; split; intros Hy; subst; try inversion Hy; auto.
- constructor.
- subst. apply IHx in H2. congruence.
- constructor. apply IHx. reflexivity.
Qed.

Parametricity Recursive bool.
Lemma bool_R_eq : forall x y , bool_R x y <=> x = y.
Proof.
  induction x; intros y; split; intros Hy; subst; try inversion Hy; auto;
constructor.
Qed.

Lemma nat_R_refl : forall t, nat_R t t.
Proof. 
  intros. apply nat_R_eq. reflexivity.
Qed.



Definition rInv {T1 T2 T3: Type} (R: T1 -> T2 -> T3) :=
  fun a b => R b a.

Definition TotalHeteroRelHalf {T1 T2 : Type} (R: T1 -> T2 -> Type) : Type :=
(forall (t1:T1), @sigT T2 (R t1)).


Definition TotalHeteroRel {T1 T2 : Type} (R: T1 -> T2 -> Type) : Type :=
(TotalHeteroRelHalf R) *
(TotalHeteroRelHalf (rInv R)).


Definition Prop_R {A B : Prop} (R : A -> B -> Prop) : Prop 
 := (A <-> B) /\ (forall a b, R a b).


Definition symHeteroRelProp (P: forall {T1 T2 : Type}, (T1 -> T2 -> Type)->Type) :=
  forall {T1 T2 : Type} (R : T1 -> T2 -> Type) , P R -> P (rInv R).

Lemma TotalHeteroRelSym  :
symHeteroRelProp (@TotalHeteroRel).
Proof using.
  unfold symHeteroRelProp,TotalHeteroRel.
  tauto.
Qed.

Hint Resolve @TotalHeteroRelSym : rInv.


(*
Lemma propForalClosedP (P: forall {A:Type}, A -> Prop)
  (trb: forall {A₁ A₂ : Type} (A_R : A₁ -> A₂ -> Type) 
      (tra: TotalHeteroRel A_R) a₁ a₂,
          A_R a₁ a₂ -> (P a₁ <-> P a₂)):
   let newP (A:Type):= (forall a:A, P a) in
   forall  {A₁ A₂ : Type} (A_R : A₁ -> A₂ -> Type) 
      (tra: TotalHeteroRel A_R), newP A₁ <-> newP A₂.
Proof using.
  simpl. intros.
  split; intros Hyp; intros a.
- destruct (snd tra a) as [ap]. unfold rInv in r.
  specialize (Hyp ap). eapply trb in r; eauto.
  tauto.
- destruct (fst tra a) as [ap]. rename a0 into r. unfold rInv in r.
  specialize (Hyp ap). eapply trb in r; eauto.
  tauto.
Qed.
*)

Inductive sigTP (A : Type) (P : A -> Type) : Prop :=
    existTP : forall x : A, P x -> sigTP A P.

Lemma sigTP_ex  (A : Type) (P : A -> Prop) :
  @sigTP A P <-> @ex A P.
Proof using.
  split; intros X; destruct X; econstructor; eauto.
Qed.

Definition TotalHeteroRelP {T1 T2 : Type} (R: T1 -> T2 -> Type) : Prop :=
(forall (t1:T1), @sigTP T2 (R t1))*
(forall (t2:T2), @sigTP _ (fun t1:T1 => R t1 t2)).

Lemma sigT_sigTP  (A : Type) (P : A -> Type) :
  @sigTP A P -> @sigT A P.
Proof using.
  intros X.
  Fail destruct X.
Abort. (* not provable *)

Lemma sigT_sigTP  (A : Type) (P : A -> Type) :
  @sigT A P -> sigTP A P.
Proof using.
  intros X. destruct X. econstructor; eauto.
Qed.

Lemma implies_TotalHeteroRelP {T1 T2 : Type} (R: T1 -> T2 -> Type) :
  TotalHeteroRelP R -> TotalHeteroRel R.
Proof.
  unfold  TotalHeteroRel, TotalHeteroRelHalf, TotalHeteroRelP.
  firstorder.
Abort. (* not provable *)

Lemma implies_TotalHeteroRelP {T1 T2 : Type} (R: T1 -> T2 -> Type) :
  TotalHeteroRel R -> TotalHeteroRelP R.
Proof.
  unfold  TotalHeteroRel, TotalHeteroRelP.
  firstorder.
Qed.



Require Import Coq.Logic.ExtensionalityFacts.

Definition iso (A B : Type) :=
sigT (fun f:A->B => sigT (fun g:B->A => is_inverse f g)).

(* note that this is, even classically, weaker than saying that
A and B are isomorphic. There may be things in A that are not in B.
However, it we also need to qualtify over the polymorphic type,
we would also need HeteroRel. Then, atleast classically,
the two imply isomorphism *)
Definition oneToOneHalf  {A B : Type} (R : A -> B -> Type) : Prop :=
forall a1 a2 b1 b2,
  R a1 b1
  -> R a2 b2
  -> a1=a2 -> b1=b2.

Definition oneToOne  {A B : Type} (R : A -> B -> Type) : Prop :=
oneToOneHalf R /\ (oneToOneHalf (rInv R)).

Lemma oneToOneOld {A B : Type} (R : A -> B -> Type):
(forall a1 a2 b1 b2,
  R a1 b1
  -> R a2 b2
  -> (a1=a2 <-> b1=b2))
<-> oneToOne R.
Proof using.
  unfold oneToOne, oneToOneHalf.
  firstorder; subst;
  eapply H; eauto.
Qed.


Require Import Coq.Setoids.Setoid.

Lemma oneToOneSym:  symHeteroRelProp (@oneToOne).
Proof using.
  unfold symHeteroRelProp, oneToOne, oneToOneHalf, rInv.
  intros. firstorder.
Qed.

Hint Resolve oneToOneSym : rInv.

(* not in use *)
Definition rellIrrUptoIff  {A B : Type} (R : A -> B -> Type)  :=
 forall (TR: forall {a b}, (R a b)->Type) a b (p1 p2: R a b),
  TR p1 -> TR p2.

Require Import SquiggleEq.UsefulTypes.

(*
Lemma relIrrUptoEq  {A B : Type} (R : A -> B -> Type) :
rellIrrUptoIff R ->
forall a b (p1 p2: R a b), p1=p2.
Proof using.
  intros Hr ? ? ? ?.
  specialize (Hr (fun a' b' p => forall (pa:a = a') (pb:b=b'), p= 
    transport pb (@transport _ _ _ (fun x => R x b) pa p1)) a b p1 p2
    ).
  simpl in Hr.
  specialize (fun p => Hr p eq_refl eq_refl). simpl in Hr.
  symmetry. apply Hr.
  intros. unfold transport.
  (* need UIP_refl to finish the proof *)
Abort.
*)

(* was something like this needed to define type families in Nuprl? *)
Definition relIrrUptoEq  {A B : Type} (R : A -> B -> Type)  :=
 forall  a b (p1 p2: R a b), p1 = p2.

Definition rellIrrUptoEq4  {A B : Type} (R : A -> B -> Type)  :=
 forall  a1 b1 a2 b2 (p1 : R a1 b1) (p2 : R a2 b2) (e1:a1=a2) (e2:b1=b2),
    p2 = (transport e2 (@transport _ _ _ (fun x => R x b1) e1 p1)).

Lemma rellIrrUptoEq4_implies {A B : Type} (R : A -> B -> Type):
   rellIrrUptoEq4 R ->  relIrrUptoEq R .
Proof.
  intros H4 ? ? ? ?.
  specialize (H4 _ _ _ _ p1 p2 eq_refl eq_refl).
  simpl in H4.
  auto.
Qed.


Lemma irrelSym : 
  symHeteroRelProp (@relIrrUptoEq).
Proof using.
  unfold symHeteroRelProp,relIrrUptoEq, rInv.
  intros. eauto.
Qed.

Hint Resolve irrelSym : rInv.



Definition R_Pi {A1 A2 :Type} {A_R: A1 -> A2 -> Type}
  {B1: A1 -> Type}
  {B2: A2 -> Type} 
  (B_R: forall {a1 a2}, A_R a1 a2 -> (B1 a1) -> (B2 a2) -> Type)
  (f1: forall a, B1 a) (f2: forall a, B2 a) : Type
  :=
  forall a1 a2 (p: A_R a1 a2), B_R p (f1 a1) (f2 a2).

Definition rPiInv 
{A1 A2 :Type} {A_R: A1 -> A2 -> Type}
  {B1: A1 -> Type}
  {B2: A2 -> Type} 
  (B_R: forall a1 a2, A_R a1 a2 -> (B1 a1) -> (B2 a2) -> Type) :=
fun a2 a1 a_R => rInv (B_R a1 a2 a_R).

Lemma rPiInvPreservesSym
(P: forall {T1 T2 : Type}, (T1 -> T2 -> Type)->Type)
(sp: symHeteroRelProp (@P))
{A1 A2 :Type} {A_R: A1 -> A2 -> Type}
  {B1: A1 -> Type}
  {B2: A2 -> Type} 
  {B_R: forall a1 a2, A_R a1 a2 -> (B1 a1) -> (B2 a2) -> Type}
  (trb: forall a1 a2 (p:A_R a1 a2), P (B_R _ _ p)):
 (forall (a1 : A2) (a2 : A1) (p : rInv A_R a1 a2), P (rPiInv B_R a1 a2 p)).
Proof using.
  intros.

  eauto.
Qed.

Ltac rInv
  := (eauto with rInv; unfold rInv, symHeteroRelProp in *; try apply rPiInvPreservesSym;
     simpl; eauto with rInv).

(*
Lemma rPiInvTotal
{A1 A2 :Type} {A_R: A1 -> A2 -> Type}
  {B1: A1 -> Type}
  {B2: A2 -> Type} 
  {B_R: forall a1 a2, A_R a1 a2 -> (B1 a1) -> (B2 a2) -> Type}
  (trb: forall a1 a2 (p:A_R a1 a2), TotalHeteroRel (B_R _ _ p)):
 (forall (a1 : A2) (a2 : A1) (p : rInv A_R a1 a2), TotalHeteroRel (rPiInv B_R a1 a2 p)).
Proof using.
  rInv.
Qed.
*)


(* TODO : put the axiomatic part in a separate file *)


Require Import ProofIrrelevance.

Lemma Prop_RSpec {A₁ A₂: Prop} (R : A₁ -> A₂ -> Prop):
  TotalHeteroRel R <=> Prop_R R.
Proof using.
  intros. split; intros Hyp;
  unfold Prop_R; unfold TotalHeteroRel, TotalHeteroRelHalf, rInv in *.
- destruct Hyp. split.
  + split; intros a; try destruct (s a);  try destruct (s0 a); eauto.
  + intros. destruct (s a).
    pose proof (proof_irrelevance _ x b). subst. assumption.
- intros. destruct Hyp. split; intros a; firstorder; eauto.
Qed.


Section Temp.
Variable A:Type.
Variable B:A->Prop.
Variable C:Set->Prop.
Variable D:Type->Prop.
Check ((forall (a:A), B a):Prop).
Check ((forall (a:Set), C a):Prop).
(* we will not be able to handle the case below because the relations for type 
dont have goodness props *)
Check ((forall (a:Type), D a):Prop).
End Temp.







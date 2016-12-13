Definition rInv {T1 T2 T3: Type} (R: T1 -> T2 -> T3) :=
  fun a b => R b a.

Definition TotalHeteroRelHalf {T1 T2 : Type} (R: T1 -> T2 -> Type) : Type :=
(forall (t1:T1), @sigT T2 (R t1)).


Definition TotalHeteroRel {T1 T2 : Type} (R: T1 -> T2 -> Type) : Type :=
(TotalHeteroRelHalf R) *
(TotalHeteroRelHalf (rInv R)).

Lemma TotalHeteroRelSym {T1 T2 : Type} (R: T1 -> T2 -> Type) : 
  TotalHeteroRel R ->  TotalHeteroRel (rInv R).
Proof using.
  unfold TotalHeteroRel.
  tauto.
Qed.

Lemma propForalClosedP (P: forall {A:Type}, A -> Prop)
  (pg: forall {A₁ A₂ : Type} (A_R : A₁ -> A₂ -> Type) 
      (tra: TotalHeteroRel A_R) a₁ a₂,
          A_R a₁ a₂ -> (P a₁ <-> P a₂)):
   let newP (A:Type):= (forall a:A, P a) in
   forall  {A₁ A₂ : Type} (A_R : A₁ -> A₂ -> Type) 
      (tra: TotalHeteroRel A_R), newP A₁ <-> newP A₂.
Proof using.
  simpl. intros.
  split; intros Hyp; intros a.
- destruct (snd tra a) as [ap]. unfold rInv in r.
  specialize (Hyp ap). eapply pg in r; eauto.
  tauto.
- destruct (fst tra a) as [ap]. rename a0 into r. unfold rInv in r.
  specialize (Hyp ap). eapply pg in r; eauto.
  tauto.
Qed.

Declare ML Module "paramcoq".

Notation "a <=> b" := (prod (a->b) (b->a)) (at level 100).

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
Abort.

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
Abort.

Lemma implies_TotalHeteroRelP {T1 T2 : Type} (R: T1 -> T2 -> Type) :
  TotalHeteroRel R -> TotalHeteroRelP R.
Proof.
  unfold  TotalHeteroRel, TotalHeteroRelP.
  firstorder.
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

Require Import Coq.Logic.ExtensionalityFacts.

Definition iso (A B : Type) :=
sigT (fun f:A->B => sigT (fun g:B->A => is_inverse f g)).

(* note that this is, even classically, weaker than saying that
A and B are isomorphic. There may be things in A that are not in B.
However, it we also need to qualtify over the polymorphic type,
we would also need HeteroRel. Then, atleast classically,
the two imply isomorphism *)
Definition oneToOne  {A B : Type} (R : A -> B -> Type) : Prop :=
forall a1 a2 b1 b2,
  R a1 b1
  -> R a2 b2
  -> (a1=a2 <-> b1=b2).

Definition R_Pi {A1 A2 :Type} {A_R: A1 -> A2 -> Type}
  {B1: A1 -> Type}
  {B2: A2 -> Type} 
  (B_R: forall {a1 a2}, A_R a1 a2 -> (B1 a1) -> (B2 a2) -> Type)
  (f1: forall a, B1 a) (f2: forall a, B2 a) : Type
  :=
  forall a1 a2 (p: A_R a1 a2), B_R p (f1 a1) (f2 a2).

Definition R_Fun {A1 A2 :Type} (A_R: A1 -> A2 -> Type)
  {B1 B2: Type}
  (B_R: B1 -> B2 -> Type)
  (f1: A1->B1) (f2: A2->B2) : Type
  :=
  @R_Pi A1 A2 A_R (fun _ => B1) (fun _ => B2)
  (fun _ _ _ => B_R) f1 f2.

(* the case of non-dependent functions is interesting because no extra 
[irrel] hypothesis is needed.*)
Lemma totalFun (A1 A2 :Type) (A_R: A1 -> A2 -> Type) 
  {B1 B2: Type}
  (B_R: B1 -> B2 -> Type)
  (trp : TotalHeteroRel A_R)
  (trb: TotalHeteroRel B_R)
  (oneToOneA_R: oneToOne A_R)
:
  TotalHeteroRel (R_Fun A_R B_R).
Proof.
  split.
- intros f1. apply snd in trp.
  eexists.
  Unshelve.
    Focus 2.
    intros a2. specialize (trp a2).
     destruct trp as [a11 ar].
    apply fst in trb.
    specialize (trb (f1 a11)).
    exact (projT1  trb).

  simpl.
  intros ? ? ?.
  destruct (trp a2) as [a1r ar].
  destruct (trb) as [b2 br].
  simpl.
  destruct (b2 (f1 a1r)). simpl.
  pose proof (proj2 (oneToOneA_R _ _ _ _ p ar) eq_refl).
  subst.
  assumption.
- intros f1. apply fst in trp.
  eexists.
  Unshelve.
    Focus 2.
    intros a2. specialize (trp a2).
     destruct trp as [a11 ar].
    apply snd in trb.
    specialize (trb (f1 a11)).
    exact (projT1  trb).

  simpl.
  intros a2 ? p.
  destruct (trp a2) as [a1r ar].
  destruct (trb) as [b2 br].
  simpl.
  destruct (br (f1 a1r)). simpl.
  pose proof (proj1 (oneToOneA_R _ _ _ _ p ar) eq_refl).
  subst.
  assumption.
Qed.

Require Import Coq.Logic.FunctionalExtensionality.

Lemma oneToOnePi (A1 A2 :Type) (A_R: A1 -> A2 -> Type) 
  (B1: A1 -> Type) 
  (B2: A2 -> Type) 
  (B_R: forall a1 a2, A_R a1 a2 -> (B1 a1) -> (B2 a2) -> Type)
  (tra : TotalHeteroRel A_R) 
  (oneToOneB_R: forall a1 a2 (a_r : A_R a1 a2), oneToOne (B_R a1 a2 a_r))
:
  oneToOne (R_Pi B_R).
Proof.
  intros f1 g1 f2 g2 H1r H2r.
  unfold R_Fun, R_Pi in *.
  split; intros Heq;subst; apply functional_extensionality_dep.
- intros a2.
  destruct (snd tra a2) as [a1 a1r].
  specialize (H2r _ _ a1r).
  specialize (H1r _ _ a1r).
  pose proof (proj1 (oneToOneB_R _ _ _ _ _ _ _ H2r H1r) eq_refl).
  auto.
- intros a2.
  destruct (fst tra a2) as [a1 a1r].
  specialize (H2r _ _ a1r).
  specialize (H1r _ _ a1r).
  pose proof (proj2 (oneToOneB_R _ _ _ _ _ _ _ H2r H1r) eq_refl).
  auto.
Qed.


Definition rellIrrUptoIff  {A B : Type} (R : A -> B -> Type)  :=
 forall (TR: forall {a b}, (R a b)->Type) a b (p1 p2: R a b),
  TR p1 -> TR p2.



Definition transport {T:Type} {a b:T} {P:T -> Type} (eq:a=b) (pa: P a) : (P b):=
@eq_rect T a P pa b eq.

Lemma rellIrrUptoEq  {A B : Type} (R : A -> B -> Type) :
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

(* was something like this needed to define type families in Nuprl? *)
Definition rellIrrUptoEq  {A B : Type} (R : A -> B -> Type)  :=
 forall  a b (p1 p2: R a b), p1 = p2.

Definition rellIrrUptoEq4  {A B : Type} (R : A -> B -> Type)  :=
 forall  a1 b1 a2 b2 (p1 : R a1 b1) (p2 : R a2 b2) (e1:a1=a2) (e2:b1=b2),
    p2 = (transport e2 (@transport _ _ _ (fun x => R x b1) e1 p1)).

Lemma rellIrrUptoEq4_implies {A B : Type} (R : A -> B -> Type):
   rellIrrUptoEq4 R ->  rellIrrUptoEq R .
Proof.
  intros H4 ? ? ? ?.
  specialize (H4 _ _ _ _ p1 p2 eq_refl eq_refl).
  simpl in H4.
  auto.
Qed.




Lemma totalPiHalf (A1 A2 :Type) (A_R: A1 -> A2 -> Type) 
  (trp : TotalHeteroRel A_R) 
  (B1: A1 -> Type) 
  (B2: A2 -> Type) 
  (B_R: forall a1 a2, A_R a1 a2 -> (B1 a1) -> (B2 a2) -> Type)
  (trb: forall a1 a2 (p:A_R a1 a2), TotalHeteroRel (B_R _ _ p))
  (oneToOneA_R: oneToOne A_R)
  (irrel : rellIrrUptoEq A_R)
:
  TotalHeteroRelHalf (R_Pi B_R).
Proof.
  intros f1. apply snd in trp.
  eexists.
  Unshelve.
    Focus 2.
    intros a2. specialize (trp a2).
    destruct trp as [a1 ar]. (* this step fails with TotalHeteroRelP *)
    specialize (trb _ _ ar).
    apply fst in trb.
    specialize (trb (f1 a1)).
    exact (projT1 trb).

  simpl.
  intros ? ? par. (** [par] comes from intros in the Totality proof *)
  destruct (trp a2) as [a11 far].
  unfold rInv in far.
  (** [far] was obtained by destructing [trb] in the exhibited function.
     Right now, the types of [par] and [dar] are not even same ([a11] vs [a1]).*)
  pose proof (proj2 (oneToOneA_R _ _ _ _ par far) eq_refl) as Heq.
  symmetry in Heq. subst.
  (* now the types of [far] and [par] are same. Why would they be same, though? *)
  destruct (trb a1 a2 far) as [b2 br].
  simpl.
  destruct (b2 (f1 a1)). simpl.
  specialize (irrel _ _ par far).
  subst. assumption.
Defined.

Definition rPiInv 
{A1 A2 :Type} {A_R: A1 -> A2 -> Type}
  {B1: A1 -> Type}
  {B2: A2 -> Type} 
  (B_R: forall a1 a2, A_R a1 a2 -> (B1 a1) -> (B2 a2) -> Type) :=
fun a2 a1 a_R => rInv (B_R a1 a2 a_R).

Lemma rPiInvSym
{A1 A2 :Type} {A_R: A1 -> A2 -> Type}
  {B1: A1 -> Type}
  {B2: A2 -> Type} 
  {B_R: forall a1 a2, A_R a1 a2 -> (B1 a1) -> (B2 a2) -> Type}
  (trb: forall a1 a2 (p:A_R a1 a2), TotalHeteroRel (B_R _ _ p)):
 (forall (a1 : A2) (a2 : A1) (p : rInv A_R a1 a2), TotalHeteroRel (rPiInv B_R a1 a2 p)).
Proof using.
  intros.
  unfold TotalHeteroRel, TotalHeteroRelHalf, rPiInv, rInv in *.
  firstorder.
Qed.

Require Import Coq.Setoids.Setoid.

Lemma oneToOneSym {T1 T2 : Type} {R: T1 -> T2 -> Type} : 
  oneToOne R ->  oneToOne (rInv R).
Proof using.
  unfold oneToOne, rInv.
  intros.
  rewrite H; eauto.
  reflexivity.
Qed.

Lemma irrelSym {T1 T2 : Type} {R: T1 -> T2 -> Type}: 
  rellIrrUptoEq R ->  rellIrrUptoEq (rInv R).
Proof using.
  unfold rellIrrUptoEq, rInv.
  intros. eauto.
Qed.


Lemma totalPi (A1 A2 :Type) (A_R: A1 -> A2 -> Type) 
  (trp : TotalHeteroRel A_R) 
  (B1: A1 -> Type) 
  (B2: A2 -> Type) 
  (B_R: forall a1 a2, A_R a1 a2 -> (B1 a1) -> (B2 a2) -> Type)
  (trb: forall a1 a2 (p:A_R a1 a2), TotalHeteroRel (B_R _ _ p))
  (oneToOneA_R: oneToOne A_R)
  (irrel : rellIrrUptoEq A_R)
:
  TotalHeteroRel (R_Pi B_R).
Proof.
  split.
- apply totalPiHalf; auto.
- apply TotalHeteroRelSym in trp.
  pose proof (@totalPiHalf _ _ (rInv A_R) trp B2 B1 (rPiInv B_R)
     (rPiInvSym trb) (oneToOneSym oneToOneA_R)
     (irrelSym irrel)).
  unfold R_Pi, rPiInv, rInv in *.
  intros ?.
  unfold TotalHeteroRelHalf in X.
  intros.
  destruct X with (t1:=t1).
  eexists; intros; eauto.
Qed.



Lemma irrelEqPi (A1 A2 :Type) (A_R: A1 -> A2 -> Type) 
  (trp : TotalHeteroRel A_R) 
  (B1: A1 -> Type) 
  (B2: A2 -> Type) 
  (B_R: forall a1 a2, A_R a1 a2 -> (B1 a1) -> (B2 a2) -> Type)
  (trb: forall a1 a2 (p:A_R a1 a2), TotalHeteroRel (B_R _ _ p))
  (irrelB: forall a1 a2 (a_r : A_R a1 a2), rellIrrUptoEq (B_R a1 a2 a_r))
:
  rellIrrUptoEq (R_Pi B_R).
Proof.
  intros f1 f2 ? ?.
  unfold R_Pi in *.
  apply functional_extensionality_dep.
  intros a1.
  apply functional_extensionality_dep.
  intros a2.
  apply functional_extensionality_dep.
  intros ar.
  apply irrelB.
Qed.

(* Thhe same holds for IWT -- see PIW.v *)

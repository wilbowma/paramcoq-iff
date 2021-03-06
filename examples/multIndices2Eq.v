Require Import ReflParam.common.
Require Import ReflParam.templateCoqMisc.
Require Import String.
Require Import List.
Require Import Template.Ast.
Require Import SquiggleEq.terms.
(* Require Import ReflParam.paramDirect ReflParam.indType. *)

Require Import SquiggleEq.substitution.
Require Import ReflParam.PiTypeR.
Import ListNotations.
Open Scope string_scope.


Inductive multInd (A I : Set) (B: I-> Set) (f: A-> I) (g: forall i, B i) 
  : forall i:I, B i -> Set  :=  
mlind : forall a, multInd A I B f g (f a) (g (f a)).


Require Import SquiggleEq.UsefulTypes.

(* Run TemplateProgram (genParamInd [] false true true "Top.multIndices2Eq.multInd"). *)


(*
Definition multInd_RR :=
(fix
 Top_multIndices2Eq_multInd_RR0 (A A₂ : Set) (A_R : A -> A₂ -> Prop) 
                                (I I₂ : Set) (I_R : I -> I₂ -> Prop) 
                                (B : I -> Set) (B₂ : I₂ -> Set)
                                (B_R : forall (H : I) (H0 : I₂),
                                       I_R H H0 -> B H -> B₂ H0 -> Prop) 
                                (f : A -> I) (f₂ : A₂ -> I₂)
                                (f_R : forall (H : A) (H0 : A₂),
                                       A_R H H0 -> I_R (f H) (f₂ H0))
                                (g : forall i : I, B i) (g₂ : forall i₂ : I₂, B₂ i₂)
                                (g_R : forall (i : I) (i₂ : I₂) (i_R : I_R i i₂),
                                       B_R i i₂ i_R (g i) (g₂ i₂)) 
                                (i : I) (i₂ : I₂) (i_R : I_R i i₂) 
                                (H : B i) (H0 : B₂ i₂) (H1 : B_R i i₂ i_R H H0)
                                (H2 : multInd A I B f g i H)
                                (H3 : multInd A₂ I₂ B₂ f₂ g₂ i₂ H0) {struct H2} : Prop :=
   match
     H2 in (multInd _ _ _ _ _ i0 H4)
     return (forall i_R0 : I_R i0 i₂, B_R i0 i₂ i_R0 H4 H0 -> Prop)
   with
   | mlind _ _ _ _ _ a =>
       match
         H3 in (multInd _ _ _ _ _ i₂0 H4)
         return (forall i_R0 : I_R (f a) i₂0, B_R (f a) i₂0 i_R0 (g (f a)) H4 -> Prop)
       with
       | mlind _ _ _ _ _ a₂ =>
           fun (i_R0 : I_R (f a) (f₂ a₂))
             (H4 : B_R (f a) (f₂ a₂) i_R0 (g (f a)) (g₂ (f₂ a₂))) =>
           {a_R : A_R a a₂ &
           existT
             (fun i_R1 : I_R (f a) (f₂ a₂) =>
              {_ : B_R (f a) (f₂ a₂) i_R1 (g (f a)) (g₂ (f₂ a₂)) & True}) 
             (f_R a a₂ a_R)
             (existT
                (fun _ : B_R (f a) (f₂ a₂) (f_R a a₂ a_R) (g (f a)) (g₂ (f₂ a₂)) => True)
                (g_R (f a) (f₂ a₂) (f_R a a₂ a_R)) Logic.I) =
           existT
             (fun i_R1 : I_R (f a) (f₂ a₂) =>
              {_ : B_R (f a) (f₂ a₂) i_R1 (g (f a)) (g₂ (f₂ a₂)) & True}) i_R0
             (existT (fun _ : B_R (f a) (f₂ a₂) i_R0 (g (f a)) (g₂ (f₂ a₂)) => True) H4
                Logic.I)}
       end
   end i_R H1).


Definition mlind_RRInv :=
(fun (A A₂ : Set) (A_R : A -> A₂ -> Prop) (I0 I₂ : Set) (I_R : I0 -> I₂ -> Prop)
   (B : I0 -> Set) (B₂ : I₂ -> Set)
   (B_R : forall (H : I0) (H0 : I₂), I_R H H0 -> B H -> B₂ H0 -> Prop) 
   (f : A -> I0) (f₂ : A₂ -> I₂)
   (f_R : forall (H : A) (H0 : A₂), A_R H H0 -> I_R (f H) (f₂ H0)) 
   (g : forall i : I0, B i) (g₂ : forall i₂ : I₂, B₂ i₂)
   (g_R : forall (i : I0) (i₂ : I₂) (i_R : I_R i i₂), B_R i i₂ i_R (g i) (g₂ i₂)) 
   (a : A) (a₂ : A₂) (i_R : I_R (f a) (f₂ a₂))
   (H : B_R (f a) (f₂ a₂) i_R (g (f a)) (g₂ (f₂ a₂)))
   (sigt_R : {a_R : A_R a a₂ &
             existT
               (fun i_R0 : I_R (f a) (f₂ a₂) =>
                {_ : B_R (f a) (f₂ a₂) i_R0 (g (f a)) (g₂ (f₂ a₂)) & True}) 
               (f_R a a₂ a_R)
               (existT
                  (fun _ : B_R (f a) (f₂ a₂) (f_R a a₂ a_R) (g (f a)) (g₂ (f₂ a₂)) => True)
                  (g_R (f a) (f₂ a₂) (f_R a a₂ a_R)) I) =
             existT
               (fun i_R0 : I_R (f a) (f₂ a₂) =>
                {_ : B_R (f a) (f₂ a₂) i_R0 (g (f a)) (g₂ (f₂ a₂)) & True}) i_R
               (existT (fun _ : B_R (f a) (f₂ a₂) i_R (g (f a)) (g₂ (f₂ a₂)) => True) H I)})
   (retTyp_R : forall (i_R0 : I_R (f a) (f₂ a₂))
                 (H0 : B_R (f a) (f₂ a₂) i_R0 (g (f a)) (g₂ (f₂ a₂))),
               {a_R : A_R a a₂ &
               existT
                 (fun i_R1 : I_R (f a) (f₂ a₂) =>
                  {_ : B_R (f a) (f₂ a₂) i_R1 (g (f a)) (g₂ (f₂ a₂)) & True}) 
                 (f_R a a₂ a_R)
                 (existT
                    (fun _ : B_R (f a) (f₂ a₂) (f_R a a₂ a_R) (g (f a)) (g₂ (f₂ a₂)) => True)
                    (g_R (f a) (f₂ a₂) (f_R a a₂ a_R)) I) =
               existT
                 (fun i_R1 : I_R (f a) (f₂ a₂) =>
                  {_ : B_R (f a) (f₂ a₂) i_R1 (g (f a)) (g₂ (f₂ a₂)) & True}) i_R0
                 (existT (fun _ : B_R (f a) (f₂ a₂) i_R0 (g (f a)) (g₂ (f₂ a₂)) => True) H0
                    I)} -> Set)
   (_ : forall a_R : A_R a a₂,
        retTyp_R (f_R a a₂ a_R) (g_R (f a) (f₂ a₂) (f_R a a₂ a_R))
          (existT
             (fun a_R0 : A_R a a₂ =>
              existT
                (fun i_R0 : I_R (f a) (f₂ a₂) =>
                 {_ : B_R (f a) (f₂ a₂) i_R0 (g (f a)) (g₂ (f₂ a₂)) & True}) 
                (f_R a a₂ a_R0)
                (existT
                   (fun _ : B_R (f a) (f₂ a₂) (f_R a a₂ a_R0) (g (f a)) (g₂ (f₂ a₂)) => True)
                   (g_R (f a) (f₂ a₂) (f_R a a₂ a_R0)) I) =
              existT
                (fun i_R0 : I_R (f a) (f₂ a₂) =>
                 {_ : B_R (f a) (f₂ a₂) i_R0 (g (f a)) (g₂ (f₂ a₂)) & True}) 
                (f_R a a₂ a_R)
                (existT
                   (fun _ : B_R (f a) (f₂ a₂) (f_R a a₂ a_R) (g (f a)) (g₂ (f₂ a₂)) => True)
                   (g_R (f a) (f₂ a₂) (f_R a a₂ a_R)) I)) a_R eq_refl)) =>
 fiat (retTyp_R i_R H sigt_R)).

Definition mlind_RR :=
(fun (A A₂ : Set) (A_R : A -> A₂ -> Prop) (I0 I₂ : Set) (I_R : I0 -> I₂ -> Prop)
   (B : I0 -> Set) (B₂ : I₂ -> Set)
   (B_R : forall (H : I0) (H0 : I₂), I_R H H0 -> B H -> B₂ H0 -> Prop) 
   (f : A -> I0) (f₂ : A₂ -> I₂)
   (f_R : forall (H : A) (H0 : A₂), A_R H H0 -> I_R (f H) (f₂ H0)) 
   (g : forall i : I0, B i) (g₂ : forall i₂ : I₂, B₂ i₂)
   (g_R : forall (i : I0) (i₂ : I₂) (i_R : I_R i i₂), B_R i i₂ i_R (g i) (g₂ i₂)) 
   (a : A) (a₂ : A₂) (a_R : A_R a a₂) =>
 existT
   (fun a_R0 : A_R a a₂ =>
    existT
      (fun i_R : I_R (f a) (f₂ a₂) =>
       {_ : B_R (f a) (f₂ a₂) i_R (g (f a)) (g₂ (f₂ a₂)) & True}) 
      (f_R a a₂ a_R0)
      (existT (fun _ : B_R (f a) (f₂ a₂) (f_R a a₂ a_R0) (g (f a)) (g₂ (f₂ a₂)) => True)
         (g_R (f a) (f₂ a₂) (f_R a a₂ a_R0)) I) =
    existT
      (fun i_R : I_R (f a) (f₂ a₂) =>
       {_ : B_R (f a) (f₂ a₂) i_R (g (f a)) (g₂ (f₂ a₂)) & True}) 
      (f_R a a₂ a_R)
      (existT (fun _ : B_R (f a) (f₂ a₂) (f_R a a₂ a_R) (g (f a)) (g₂ (f₂ a₂)) => True)
         (g_R (f a) (f₂ a₂) (f_R a a₂ a_R)) I)) a_R eq_refl).

Print multInd_rect.
Print nat_rect.

*)

(*
Declare ML Module "paramcoq".
Parametricity Recursive multInd_recs.
*)

Definition multInd_recs := 
fun (A I : Set) (B : I -> Set) (f : A -> I) (g : forall i : I, B i)
  (P : forall (i : I) (b : B i), multInd A I B f g i b -> Set)
  (f0 : forall a : A, P (f a) (g (f a)) (mlind A I B f g a)) (i : I) 
  (a : B i) (m : multInd A I B f g i a) =>
match m as m0 in (multInd _ _ _ _ _ i0 a0) return (P i0 a0 m0) with
| mlind _ _ _ _ _ x => f0 x
end.

Definition multInd_RR (A A₂ : Set) (A_R : A -> A₂ -> Prop) 
                              (I I₂ : Set) (I_R : I -> I₂ -> Prop) 
                              (B : I -> Set) (B₂ : I₂ -> Set)
                              (B_R : forall (H : I) (H0 : I₂),
                                     I_R H H0 -> B H -> B₂ H0 -> Prop) 
                              (f : A -> I) (f₂ : A₂ -> I₂)
                              (f_R : forall (H : A) (H0 : A₂), A_R H H0 -> I_R (f H) (f₂ H0))
                              (g : forall i : I, B i) (g₂ : forall i₂ : I₂, B₂ i₂)
                              (g_R : forall (i : I) (i₂ : I₂) (i_R : I_R i i₂),
                                     B_R i i₂ i_R (g i) (g₂ i₂)) 
                              (i : I) (i₂ : I₂) (i_R : I_R i i₂) 
                              (H : B i) (H0 : B₂ i₂) (H1 : B_R i i₂ i_R H H0)
                              (H2 : multInd A I B f g i H)
                              (H3 : multInd A₂ I₂ B₂ f₂ g₂ i₂ H0) : Prop.
refine (
   let reT i1 i2 b1 b2 := forall (ir : I_R i1 i2) (br : B_R i1 i2 ir b1 b2), Prop in
   (match H2 in multInd _ _ _ _ _ i1 b1 return reT i1 i₂ b1 H0 with
   | mlind _ _ _ _ _ a => match
     H3 in multInd _ _ _ _ _ i2 b2 return reT (f a) i2 (g (f a)) b2 with
         | mlind _ _ _ _ _ a₂ => fun ir br =>
                  {ar : A_R a a₂ & 
  @existT _ _ (f_R a a₂ ar) (g_R _ _ (f_R a a₂ ar)) = 
      @existT _ (fun ir => B_R (f a) (f₂ a₂) ir (g (f a)) (g₂ (f₂ a₂))) ir br
                  }
              end
   end) i_R H1 ).
Defined.
SearchAbout multInd.

Print sigT.
Lemma eta_sigt {A : Type} {P : A -> Type} (x: sigT P):
x = existT _ (projT1 x) (projT2 x).
Proof using.
  intros. destruct x. simpl. refl.
Defined.

(* this property is crucial *)
Lemma eta_sigt_eqrefl {A : Type} {P : A -> Type} (a:A) (p: P a):
eta_sigt (existT _ a p) = eq_refl.
Proof using.
  simpl. reflexivity.
Defined.


(* delete *)
Lemma eq_rect2
     : forall (T : Type) (x : T) (P : forall t : T, eq x t -> Type),
       P x (eq_refl x) -> forall (y : T) (e : eq x y), P y e.
Proof.
  intros.
  rewrite <-e. assumption.
Defined.

(* delete *)
Lemma eq_rect2_rev
     : forall (T : Type) (x : T) (P : forall t : T, eq t x -> Type),
       P x (eq_refl x) -> forall (y : T) (e : eq y x), P y e.
Proof.
  intros. subst.
  assumption.
Defined.

(* these can be manually proved before hand? *)
Lemma eq_rect_sigt (A : Type) (PT : A -> Type) :
let T := sigT PT in
forall (x : T) (P : forall (a:A) (p: PT a), eq x (existT _ a p) -> Type),
       P (projT1 x) (projT2 x) (eta_sigt x) -> forall (a:A) (p: PT a) (e : eq x (existT _ a p)), 
        P a p e.
Proof.
  intros. subst. exact X.
Defined.

Lemma eq_rect_sigt2 (A : Type) (PT : A -> Type) :
let T := sigT PT in
forall (x : T) (P : forall (a:A) (p: PT a), eq x (existT _ a p) -> Type),
       P (projT1 x) (projT2 x) (eta_sigt x) -> forall (a:A) (p: PT a) (e : eq x (existT _ a p)), 
        P a p e.
Proof.
  intros. revert X. revert P. revert e. revert x.
  apply (eq_rect2_rev _ _ (fun x e=>
  forall (P : forall (a0 : A) (p0 : PT a0), x = existT _ a0 p0 -> Type),
P (projT1 x) (projT2 x) (eta_sigt x) -> P a p e
)). simpl. intros. exact X.
Defined.


Eval compute in eq_rect_sigt.
Arguments existT {A} {P} x p.

Definition mlind_RR  (A₁ A₂ : Set) (A_R : A₁ -> A₂ -> Prop) (I₁ I₂ : Set) 
         (I_R : I₁ -> I₂ -> Prop) (B₁ : I₁ -> Set) (B₂ : I₂ -> Set)
         (B_R : forall (H : I₁) (H0 : I₂), I_R H H0 -> B₁ H -> B₂ H0 -> Prop) 
         (f₁ : A₁ -> I₁) (f₂ : A₂ -> I₂)
         (f_R : forall (H : A₁) (H0 : A₂), A_R H H0 -> I_R (f₁ H) (f₂ H0))
         (g₁ : forall i : I₁, B₁ i) (g₂ : forall i : I₂, B₂ i)
         (g_R : forall (i₁ : I₁) (i₂ : I₂) (i_R : I_R i₁ i₂), B_R i₁ i₂ i_R (g₁ i₁) (g₂ i₂))
         (a₁ : A₁) (a₂ : A₂) (a_R : A_R a₁ a₂):
       multInd_RR A₁ A₂ A_R I₁ I₂ I_R B₁ B₂ B_R f₁ f₂ f_R g₁ g₂ g_R 
         (f₁ a₁) (f₂ a₂) (f_R a₁ a₂ a_R) (g₁ (f₁ a₁)) (g₂ (f₂ a₂))
         (g_R (f₁ a₁) (f₂ a₂) (f_R a₁ a₂ a_R)) (mlind A₁ I₁ B₁ f₁ g₁ a₁)
         (mlind A₂ I₂ B₂ f₂ g₂ a₂).
Proof.
  simpl. exists a_R. reflexivity.
Defined.

Definition multIndices_recs:
forall (A₁ A₂ : Set) (A_R : A₁ -> A₂ -> Prop) (I₁ I₂ : Set) 
         (I_R : I₁ -> I₂ -> Prop) (B₁ : I₁ -> Set) (B₂ : I₂ -> Set)
         (B_R : forall (H : I₁) (H0 : I₂), I_R H H0 -> B₁ H -> B₂ H0 -> Prop) 
         (f₁ : A₁ -> I₁) (f₂ : A₂ -> I₂)
         (f_R : forall (H : A₁) (H0 : A₂), A_R H H0 -> I_R (f₁ H) (f₂ H0))
         (g₁ : forall i : I₁, B₁ i) (g₂ : forall i : I₂, B₂ i)
         (g_R : forall (i₁ : I₁) (i₂ : I₂) (i_R : I_R i₁ i₂), B_R i₁ i₂ i_R (g₁ i₁) (g₂ i₂))
         (P₁ : forall (i : I₁) (b : B₁ i), multInd A₁ I₁ B₁ f₁ g₁ i b -> Set)
         (P₂ : forall (i : I₂) (b : B₂ i), multInd A₂ I₂ B₂ f₂ g₂ i b -> Set)
         (P_R : forall (i₁ : I₁) (i₂ : I₂) (i_R : I_R i₁ i₂) (b₁ : B₁ i₁) 
                  (b₂ : B₂ i₂) (b_R : B_R i₁ i₂ i_R b₁ b₂)
                  (H : multInd A₁ I₁ B₁ f₁ g₁ i₁ b₁) (H0 : multInd A₂ I₂ B₂ f₂ g₂ i₂ b₂),
                multInd_RR A₁ A₂ A_R I₁ I₂ I_R B₁ B₂ B_R f₁ f₂ f_R g₁ g₂ g_R i₁ i₂ i_R b₁ b₂
                  b_R H H0 -> P₁ i₁ b₁ H -> P₂ i₂ b₂ H0 -> Set)
         (f0₁ : forall a : A₁, P₁ (f₁ a) (g₁ (f₁ a)) (mlind A₁ I₁ B₁ f₁ g₁ a))
         (f0₂ : forall a : A₂, P₂ (f₂ a) (g₂ (f₂ a)) (mlind A₂ I₂ B₂ f₂ g₂ a)),
       (forall (a₁ : A₁) (a₂ : A₂) (a_R : A_R a₁ a₂),
        P_R (f₁ a₁) (f₂ a₂) (f_R a₁ a₂ a_R) (g₁ (f₁ a₁)) (g₂ (f₂ a₂))
          (g_R (f₁ a₁) (f₂ a₂) (f_R a₁ a₂ a_R)) (mlind A₁ I₁ B₁ f₁ g₁ a₁)
          (mlind A₂ I₂ B₂ f₂ g₂ a₂)
          (mlind_RR A₁ A₂ A_R I₁ I₂ I_R B₁ B₂ B_R f₁ f₂ f_R g₁ g₂ g_R a₁ a₂ a_R)
          (f0₁ a₁) (f0₂ a₂)) ->
       forall (i₁ : I₁) (i₂ : I₂) (i_R : I_R i₁ i₂) (a₁ : B₁ i₁) 
         (a₂ : B₂ i₂) (a_R : B_R i₁ i₂ i_R a₁ a₂) (m₁ : multInd A₁ I₁ B₁ f₁ g₁ i₁ a₁)
         (m₂ : multInd A₂ I₂ B₂ f₂ g₂ i₂ a₂)
         (m_R : multInd_RR A₁ A₂ A_R I₁ I₂ I_R B₁ B₂ B_R f₁ f₂ f_R g₁ g₂ g_R i₁ i₂ i_R a₁ a₂
                  a_R m₁ m₂),
       P_R i₁ i₂ i_R a₁ a₂ a_R m₁ m₂ m_R (multInd_recs A₁ I₁ B₁ f₁ g₁ P₁ f0₁ i₁ a₁ m₁)
         (multInd_recs A₂ I₂ B₂ f₂ g₂ P₂ f0₂ i₂ a₂ m₂).
Proof using.
  intros.
  rename a_R into b_R.
  revert m_R.
  destruct m₁.
  destruct m₂.
  intros ?.
  simpl in *.
  unfold mlind_RR in H.
  destruct m_R as [a_R peq].
  (* do the remaining in a separate C_RRinv construct? *)
  specialize (H _ _ a_R).
  (* here, peq needs to change to eq_refl *)
  generalize peq.
  generalize b_R.
  generalize i_R.
  apply eq_rect_sigt. (* need to add the extra I *)
  simpl.
  exact H.
Defined.

(* see the exact below 
  exact ( eq_rect_sigt (I_R (f₁ a) (f₂ a0))
           (fun ir : I_R (f₁ a) (f₂ a0) => B_R (f₁ a) (f₂ a0) ir (g₁ (f₁ a)) (g₂ (f₂ a0)))
           (existT (f_R a a0 a_R) (g_R (f₁ a) (f₂ a0) (f_R a a0 a_R)))
           (fun (a1 : I_R (f₁ a) (f₂ a0))
              (p : B_R (f₁ a) (f₂ a0) a1 (g₁ (f₁ a)) (g₂ (f₂ a0)))
              (e : existT (f_R a a0 a_R) (g_R (f₁ a) (f₂ a0) (f_R a a0 a_R)) = existT a1 p)
            =>
            P_R (f₁ a) (f₂ a0) a1 (g₁ (f₁ a)) (g₂ (f₂ a0)) p (mlind A₁ I₁ B₁ f₁ g₁ a)
              (mlind A₂ I₂ B₂ f₂ g₂ a0) (existT a_R e) (f0₁ a) 
              (f0₂ a0)) (H _ _ a_R) i_R b_R peq).
*)

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
Open Scope string_scope.


Inductive multInd (A I : Set) (B: I-> Set) (f: A-> I) (g: forall i, B i) 
  : forall (i:I) (b:B i), Set  :=  
mlind : forall a, multInd A I B f g (f a) (g (f a)).


Require Import SquiggleEq.UsefulTypes.

Run TemplateProgram (genParamInd [] true true true "Top.multIndices2.multInd").

Require Import ReflParam.Trecord.


Definition multIndices2Tot : forall
(A A₂ : Set) 
                                     (A_R : BestRel A A₂) 
                                     (I I₂ : Set) 
                                     (I_R : BestRel I I₂) 
                                     (B : I -> Set) 
                                     (B₂ : I₂ -> Set)
                                     (B_R : forall (H : I) (H0 : I₂),
                                            BestR I_R H H0 ->
                                            BestRel (B H) (B₂ H0))
                                     (f : A -> I) 
                                     (f₂ : A₂ -> I₂)
                                     (f_R : BestR
                                              (PiTSummary A A₂ A_R
                                                 (fun _ : A => I)
                                                 (fun _ : A₂ => I₂)
                                                 (fun 
                                                 (H : A) 
                                                 (H0 : A₂)
                                                 (_ : BestR A_R H H0) => I_R))
                                              f f₂) 
                                     (g : forall i : I, B i)
                                     (g₂ : forall i₂ : I₂, B₂ i₂)
                                     (g_R : BestR
                                              (PiTSummary I I₂ I_R
                                                 (fun i : I => B i)
                                                 (fun i₂ : I₂ => B₂ i₂)
                                                 (fun 
                                                 (i : I) 
                                                 (i₂ : I₂)
                                                 (i_R : BestR I_R i i₂) =>
                                                 B_R i i₂ i_R)) g g₂) 
                                     (i : I) (i₂ : I₂) 
                                     (i_R : BestR I_R i i₂) 
                                     (b : B i) (b₂ : B₂ i₂)
                                     (b_R : BestR (B_R i i₂ i_R) b b₂)
                                     (H : multInd A I B f g i b),
   multInd A₂ I₂ B₂ f₂ g₂ i₂ b₂ .
refine(
(fix
 Top_multIndices2_multInd_pmtcty_RR0 (A A₂ : Set) 
                                     (A_R : BestRel A A₂) 
                                     (I I₂ : Set) 
                                     (I_R : BestRel I I₂) 
                                     (B : I -> Set) 
                                     (B₂ : I₂ -> Set)
                                     (B_R : forall (H : I) (H0 : I₂),
                                            BestR I_R H H0 ->
                                            BestRel (B H) (B₂ H0))
                                     (f : A -> I) 
                                     (f₂ : A₂ -> I₂)
                                     (f_R : BestR
                                              (PiTSummary A A₂ A_R
                                                 (fun _ : A => I)
                                                 (fun _ : A₂ => I₂)
                                                 (fun 
                                                 (H : A) 
                                                 (H0 : A₂)
                                                 (_ : BestR A_R H H0) => I_R))
                                              f f₂) 
                                     (g : forall i : I, B i)
                                     (g₂ : forall i₂ : I₂, B₂ i₂)
                                     (g_R : BestR
                                              (PiTSummary I I₂ I_R
                                                 (fun i : I => B i)
                                                 (fun i₂ : I₂ => B₂ i₂)
                                                 (fun 
                                                 (i : I) 
                                                 (i₂ : I₂)
                                                 (i_R : BestR I_R i i₂) =>
                                                 B_R i i₂ i_R)) g g₂) 
                                     (i : I) (i₂ : I₂) 
                                     (i_R : BestR I_R i i₂) 
                                     (b : B i) (b₂ : B₂ i₂)
                                     (b_R : BestR (B_R i i₂ i_R) b b₂)
                                     (H : multInd A I B f g i b) {struct H} :
   multInd A₂ I₂ B₂ f₂ g₂ i₂ b₂ :=
   match
     H in (multInd _ _ _ _ _ i0 b0)
     return
       (forall (i₂0 : I₂) (b₂0 : B₂ i₂0) (i_R0 : BestR I_R i0 i₂0),
        BestR (B_R i0 i₂0 i_R0) b0 b₂0 -> multInd A₂ I₂ B₂ f₂ g₂ i₂0 b₂0)
   with
   | mlind _ _ _ _ _ a =>
       fun (i₂0 : I₂) (b₂0 : B₂ i₂0) (i_R0 : BestR I_R (f a) i₂0)
         (br : BestR (B_R (f a) i₂0 i_R0) (g (f a)) b₂0) =>
       let a₂ := BestTot12 A_R a in
       let a_R := BestTot12R A_R a in 
       let c2 := (mlind A₂ I₂ B₂ f₂ g₂ a₂) in _
   end i₂ b₂ i_R b_R)).
   (* take the (combine cRetIndices indIndices) and go one by one. proof by induction on cRetIndices.
      forall (pair : list (TransArg STerm* TransArg Arg) ) c2:STerm, STerm 
   if pair = nil, return c2
   if pair = (ch, ih:IH)::tl then 
   @BestOne12 IH (tprime IH) (translate IH) ch ih (ptime ch) ir0 (translate ch)
   in transport 
   in tl, do some substitutions
    *)
   set (peq := @BestOne12 I I₂ I_R (f a) i₂0 (f₂ a₂) i_R0 (f_R a a₂ a_R)).
   set (c22 := @transport _ _ _ 
      (fun i2:I₂ => multInd A₂ I₂ B₂ f₂ g₂ i2 
           (g₂ i2(*we had to convert this from (f₂ a₂) in c2 *)))
          peq c2).
   simpl in c22.
   
  set (peq2 :=
@BestOne12 (B (f a)) (B₂ i₂0) (B_R (f a) i₂0 i_R0) (g (f a)) b₂0 
           (g₂ i₂0) br (g_R (f a) i₂0 (*we had to convert this from (f₂ a₂) in c2 *) i_R0)).
  exact (@transport (B₂ i₂0) (g₂ i₂0) b₂0 (multInd A₂ I₂ B₂ f₂ g₂ i₂0) peq2 c22).
Defined.

(*   
   Run TemplateProgram (genParamIndTot [] true true "Top.multIndices2.multInd").
*)




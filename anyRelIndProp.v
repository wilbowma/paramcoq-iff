

(* coqide -top ReflParam.paramDirect paramDirect.v *)

Require Import Coq.Classes.DecidableClass.
Require Import Coq.Lists.List.
Require Import Coq.Bool.Bool.
Require Import SquiggleEq.export.
Require Import SquiggleEq.UsefulTypes.
Require Import SquiggleEq.list.
Require Import SquiggleEq.LibTactics.
Require Import SquiggleEq.tactics.
Require Import SquiggleEq.AssociationList.
Require Import ExtLib.Structures.Monads.
Require Import templateCoqMisc.
Require Import Template.Template.
Require Import Template.Ast.
Require Import NArith.
Require Import Coq.Program.Program.
Open Scope program_scope.
Require Import Coq.Init.Nat.
Require Import SquiggleEq.varInterface.
Require Import SquiggleEq.varImplDummyPair.
Require Import ReflParam.paramDirect.




(* This file implements inductive-style translation of inductive props *)

(* The [translate] translate [mkInd i] to a constant, as needed 
  in the deductive style, where the constant is a fixpoint (of the form [mkConst c]), 
and not an in the form [mkInd c].
In the inductive style, which is used for Props,
 the translation of an inductive is an inductive (of the form mkInd ir).
 We instead use mkInd (propAuxname ir).
 Then we make a constant wrapper defining ir:=mkInd (propAuxname ir).
Thus, [translate] does not worry about whether an inductive [i] was Prop 
(whether it was translated in deductive style) 
*)


Definition propAuxName (n: ident) : ident := n.
  (*String.append n "_prop". *)


(* similar to [[T]] t t, but produces a normalized result if T is a Pi type *)
Definition transTermWithPiType (ienv: indEnv) (t T: STerm) :=
      let (retTyp, args) := getHeadPIs T in
      let tlR := translate AnyRel ienv (headPisToLams T) in
      let (retTyp_R,args_R) := getNHeadLams (3* (length args)) tlR in
      let tapp := mkApp t (map (vterm ∘ fst) args) in
      mkPiL (mrs args_R) (mkAppBeta (retTyp_R) [tapp; tprime tapp]).

Definition  translateIndConstr (ienv: indEnv) (tind: inductive)
            (indRefs: list inductive)
            (numInds (*# inds in this mutual block *) : nat)
            (c: (nat*(ident * SBTerm))) : (*c_R*)  (ident * SBTerm)  :=
  let '(cindex, (cname, cbtype)) := c in
  let (bvars, ctype) := cbtype in
  let mutBVars := firstn numInds bvars in
  let paramBVars := skipn numInds bvars in
  (* for each I in the mutual block, we are defining I_R in the new mutual block *)
  let mutBVarsR := map vrel mutBVars  in 
  (* I_R has 3 times the old params *)
  let paramBVarsR := flat_map vAllRelated paramBVars in
  let ctypeR :=
      let thisConstr := mkApp (mkConstr tind cindex) (map vterm paramBVars) in
      let ctypeRAux := transTermWithPiType ienv thisConstr ctype in
      let sub :=
          let terms := map (fun i => mkConstInd i) indRefs in
          combine mutBVars terms in
      let subPrime :=
          let terms := map (fun i => mkConstInd i) indRefs in
          combine (map vprime mutBVars) terms in
      ssubst_aux ctypeRAux (sub++subPrime) in
  (constrTransName tind cindex, bterm (mutBVarsR++paramBVarsR) (reduce 1000 ctypeR)).


Definition  translateIndProp (ienv: indEnv) (indRefs: list inductive)
            (numInds (*# inds in this mutual block *) : nat)
            (ioind:  inductive * (simple_one_ind STerm SBTerm)) : simple_one_ind STerm SBTerm :=
  let (ind, oind) := ioind in
  let '(indName, typ, constrs) := oind in
  let indRName := (propAuxName (indTransName ind)) in
  let typR :=
      (* the simple approach of [[typ]] I I needs beta normalizing the application so
         that the reflection mechanism can extract the parameters.  *)
      (* mkAppBeta (translate AnyRel ienv typ) [mkConstInd ind; mkConstInd ind] in *)
      (* So, we directly produce the result of sufficiently beta normalizing the above. *)
      transTermWithPiType ienv (mkConstInd ind) typ in
  let constrsR := map (translateIndConstr ienv ind indRefs numInds) (numberElems constrs) in
  (indRName, typR, constrsR).


Definition  translateMutIndProp  (ienv: indEnv)
            (id:ident) (mind: simple_mutual_ind STerm SBTerm)
  : simple_mutual_ind STerm SBTerm :=
  let (paramNames, oneInds) := mind in
  let indRefs : list inductive := map fst (indTypes id mind) in
  let packets := combine indRefs oneInds in
  let numInds := length oneInds in
  let onesR := map (translateIndProp ienv indRefs numInds) packets in
  let paramsR := flat_map (fun n => [n;n;n]) paramNames in
                 (* contents are gargabe: only the length matters while reflecting*) 
  (paramsR, onesR).

Import MonadNotation.
Open Scope monad_scope.

(* Move *)
Definition tmReducePrint {T:Set} (t: T) : TemplateMonad () :=
  (trr <- tmReduce Ast.all t;; tmPrint trr).

Definition genParamIndProp (ienv : indEnv)  (cr:bool) (id: ident) : TemplateMonad unit :=
  id_s <- tmQuoteSq id true;;
(*  _ <- tmPrint id_s;; *)
  match id_s with
  Some (inl t) => ret tt
  | Some (inr t) =>
    let mindR := translateMutIndProp ienv id t in
    if cr then (tmMkIndSq mindR)  else  (tmReducePrint mindR)
      (* repeat for other inds in the mutual block *)
  | _ => ret tt
  end.

Section IndTrue.
  Variable (b21 : bool).

  Let maybeSwap {A:Set} (p:A*A) := (if b21 then (snd p, fst p) else p).
  Let targi {A}  := if b21 then @TranslatedArg.argPrime A else @TranslatedArg.arg A.
  Let targj {A}  := if b21 then @TranslatedArg.arg A else @TranslatedArg.argPrime A.

  Variable ienv: indEnv.
  Let translate := translate true ienv.


  (*
Definition translateOnePropBranch  (iffOnly:bool (* false => total*))
             (* v : the main (last) input to totality *)
             (ind : inductive) (totalTj: STerm) (vi vj :V) (params: list Arg)
             (castedParams_R : list STerm)
           (indIndicess indPrimeIndicess indRelIndices : list (V*STerm))
           (indAppParamsj: STerm)
  (cinfo_RR : IndTrans.ConstructorInfo): STerm := 
  let constrIndex :=  IndTrans.index cinfo_RR in
  let constrArgs_R := IndTrans.args_R cinfo_RR in
  let procArg  (p: TranslatedArg.T Arg) (t:STerm): STerm:=
    let (T11, T22,TR) := p in
    let (Ti, Tj) := maybeSwap (T11, T22) in  
    let isRec :=  (isConstrArgRecursive ind (argType Ti)) in
    if isRec
    then
      (if iffOnly
       then recursiveArgIff p (numPiArgs (argType Ti)) t
       else recursiveArgTot castedParams_R p t)
    else
      mkLetIn (argVar Tj) (fst (totij p (vterm (argVar Ti)))) (argType Tj)
        (mkLetIn (argVar TR) (snd (totij p (vterm (argVar Ti)))) 
                 (argType TR) t) in
  (* todo : use IndTrans.thisConstr *)
  let c11 := mkApp (mkConstr ind constrIndex) (map (vterm∘fst) params) in
  let c11 := mkApp c11 (map (vterm∘fst∘TranslatedArg.arg) constrArgs_R) in
  let c22 := tprime c11 in
  let (ci, cj) := maybeSwap (c11, c22) in
  let (indicesIndi, indicesIndj) := maybeSwap (indIndicess,indPrimeIndicess) in
  let (cretIndicesi, cretIndicesj) :=
      maybeSwap (IndTrans.indices cinfo_RR, IndTrans.indicesPrimes cinfo_RR) in
  let thisBranchSubi :=
      (* specialize the return type to the indices. later even the constructor is substed*)
      (combine (map fst indicesIndi) cretIndicesi) in
  let indRelIndices : list (V*STerm) :=
      ALMapRange (fun t => ssubst_aux t thisBranchSubi) indRelIndices in
  (* after rewriting with oneOnes, the indicesPrimes become (map tprime cretIndices)*)
  let thisBranchSubj :=  (combine (map fst indicesIndj) cretIndicesj) in
  let indRelArgsAfterRws : list (V*STerm) :=
      ALMapRange (fun t => ssubst_aux t thisBranchSubj) indRelIndices in
  let (c2MaybeTot, c2MaybeTotBaseType) :=
      if iffOnly
      then (cj,indAppParamsj)
      else
        let thisBranchSubFull := snoc thisBranchSubi (vi, ci) in
        let retTRR := ssubst_aux totalTj (thisBranchSubFull) in
        let retTRRLam := mkLamL indicesIndj (mkPiL indRelIndices retTRR)  in
        let crr :=
            mkConstApp (constrTransTotName ind constrIndex)
                       (castedParams_R
                          ++(map (vterm ∘ fst)
                                 (TranslatedArg.merge3way constrArgs_R))
                          ++ (map (vterm ∘ fst) indRelIndices)) in
        (mkLamL
           indRelArgsAfterRws
           (sigTToExistT2 [cj] crr (ssubst_aux retTRR thisBranchSubj))
         ,retTRRLam) in
  (* do the rewriting with OneOne *)
  let c2rw :=
      let cretIndicesJRRs := combine cretIndicesj
                                    (IndTrans.indicesRR cinfo_RR) in
      mkOneOneRewrites oneOneConst
                       (combine indRelIndices (map fst indicesIndj))
                       []
                       cretIndicesJRRs
                       c2MaybeTotBaseType
                       c2MaybeTot in
  let c2rw := if iffOnly then c2rw else mkApp (c2rw) (map (vterm ∘ fst) indRelIndices) in
  let ret := List.fold_right procArg c2rw constrArgs_R in
  mkLamL ((map (removeSortInfo ∘ targi) constrArgs_R)
            ++(indicesIndj++ indRelIndices)) ret.

  
  (* TODO: use mkIndTranspacket to cut down the boilerplate *)
(** tind is a constant denoting the inductive being processed *)
Definition translateOnePropTotal (iffOnly:bool (* false => total*))
           (numParams:nat)
           (tind : inductive*(simple_one_ind STerm STerm)) : (list Arg) * fixDef True STerm :=
  let (tind,smi) := tind in
  let (nmT, constrs) := smi in
  let constrTypes := map snd constrs in
  let (_, indTyp) := nmT in
  let (_, indTypArgs) := getHeadPIs indTyp in
  let indTyp_R := translate(*f*) (headPisToLams indTyp) in
  let (_, indTypArgs_R) := getNHeadLams (3*length indTypArgs) indTyp_R  in
  let indTypArgs_RM := TranslatedArg.unMerge3way  indTypArgs_R in
  let indTypeParams : list Arg := firstn numParams indTypArgs in
  let indTypeIndices : list (V*STerm) := mrs (skipn numParams indTypArgs) in
  let indTypeParams_R : list Arg := firstn (3*numParams) indTypArgs_R in
  let indTypeIndices_R : list Arg := skipn (3*numParams) indTypArgs_R in
  let vars : list V := map fst indTypArgs in
  let indAppParamsj : STerm :=
      let indAppParams : STerm := (mkIndApp tind (map (vterm ∘ fst) indTypeParams)) in
      if b21 then indAppParams else tprime indAppParams in
  let (Ti, Tj) :=
        let T1 : STerm := (mkIndApp tind (map vterm vars)) in
        let T2 : STerm := tprime T1 in maybeSwap (T1,T2) in
  let vv : V := freshUserVar vars "tind" in
  let (vi,vj) := maybeSwap (vv, vprime vv) in
  let (totalTj, castedParams_R)   :=
      let args := flat_map (transArgWithCast ienv) indTypArgs in
      let args := map snd args in
      (mkSig vj Tj (mkConstApp (indTransName tind)
                         (args++[vterm vv; vterm (vprime vv)]))
       , firstn (3*numParams) args)  in
  let retTyp : STerm :=
      if iffOnly then Tj else totalTj in
  let indTypeIndices_RM := skipn  numParams  indTypArgs_RM in
  (* why are we splitting the indicesPrimes and indices_RR? *)
  let indPrimeIndices :=  map (removeSortInfo ∘ TranslatedArg.argPrime) indTypeIndices_RM in
  let indRelIndices :=  map (removeSortInfo ∘ TranslatedArg.argRel) indTypeIndices_RM in
  let (caseArgsi, caseArgsj) := maybeSwap (indTypeIndices, indPrimeIndices) in
  let caseRetAllArgs :=  (caseArgsj++indRelIndices) in
  let caseRetTyp := mkPiL caseRetAllArgs  retTyp in
  let caseTyp := mkLamL (snoc caseArgsi (vi,Ti)) caseRetTyp in
  let cinfo_R := mkConstrInfoBeforeGoodness tind numParams translate constrTypes in 
  let o :=
      let cargsLens : list nat := (map IndTrans.argsLen  cinfo_R) in
      (CCase (tind, numParams) cargsLens) None in
  let matcht :=
      let lnt : list STerm := [caseTyp; vterm vi]
                                ++(map (translateOnePropBranch
                                          iffOnly
                                          tind
                                          totalTj
                                          vi
                                          vj
                                          indTypeParams
                                          castedParams_R
                                          indTypeIndices
                                          indPrimeIndices
                                          indRelIndices
                                          indAppParamsj)
                                   cinfo_R) in
      oterm o (map (bterm []) lnt) in
  let matchBody : STerm :=
      mkApp matcht (map (vterm ∘ fst)  (caseArgsj++indRelIndices)) in
  (* todo, do mkLamL indTypArgs_R just like transOneInd *)
  let fixArgs :=  ((mrs (indTypeIndices_R))) in
  let allFixArgs :=  (snoc fixArgs (vi,Ti)) in
  let fbody : STerm := mkLamL allFixArgs (matchBody) in
  let ftyp: STerm := mkPiL allFixArgs retTyp in
  let rarg : nat := ((length fixArgs))%nat in
  (indTypeParams_R, {|fname := I; ftype := (ftyp, None); fbody := fbody; structArg:= rarg |}).

   *)

Section IndTrue.
  
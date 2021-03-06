From mathcomp Require Import all_ssreflect.
Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Section FinFunDef.
  Variable (aT : finType). (* domain type *)
  Variable (rT : Type). (* codomain type *)

  Inductive finfun_type : Type := Finfun of #|aT|.-tuple rT. 
  Definition finfun_of of phant (aT -> rT) := finfun_type.
  Definition fgraph f := let: Finfun t := f in t.

  Canonical finfun_subType := Eval hnf in [newType for fgraph].

  Notation "{ 'ffun' fT }" := (finfun_of (Phant fT)).
End FinFunDef.

Definition fun_of_fin aT rT f x := tnth (@fgraph aT rT f) (enum_rank x).
Coercion fun_of_fin : finfun_type >-> Funclass.
Definition finfun aT rT f := @Finfun aT rT (codom_tuple f).
Notation "[ ’ffun’ x : aT => F ]" := (finfun (fun x : aT => F)).  

Check [ffun i : 'I_4 => i + 2]. (* : {ffun 'I_4 -> nat} *)

Inductive tree3 := Leaf of nat | Node of {ffun 'I_3 -> tree3}.

Definition finfun_eqMixin aT (rT : eqType) :=
  Eval hnf in [eqMixin of @finfun_type aT rT by <:].
Canonical finfun_eqType aT (rT : eqType) :=
  Eval hnf in EqType (finfun_type aT rT) (finfun_eqMixin aT rT).

(* These are intermediate structure we don't know yet *)
Definition finfun_choiceMixin aT (rT : choiceType) :=
  [choiceMixin of finfun_type aT rT by <:].
Canonical finfun_choiceType aT rT :=
  Eval hnf in ChoiceType _ (finfun_choiceMixin aT rT).
Canonical finfun_of_choiceType (aT : finType) (rT : choiceType) :=
  Eval hnf in [choiceType of {ffun aT -> rT}].

Definition finfun_countMixin aT (rT : countType) :=
  [countMixin of finfun_type aT rT by <:].
Canonical finfun_countType aT (rT : countType) :=
  Eval hnf in CountType _ (finfun_countMixin aT rT).
Canonical finfun_subCountType aT (rT : countType) :=
  Eval hnf in [subCountType of finfun_type aT rT].

(* up there we used MC's tuples, which are already equipped with
   a finite type. This code may be played after 7.1 I guess

(* was an exercise from ch1 *)
Definition all_words n T (alphabet : seq T) :=
  let prepend x wl := [seq x :: w | w <- wl] in
  let extend wl := flatten [seq prepend x wl | x <- alphabet] in
  iter n extend [::[::]].

Definition tuple_enum (T : finType) n : seq (n.-tuple T) :=
  pmap insub (all_words n (enum T)).

Lemma enumP T n : Finite.axiom (tuple_enum T n).
Admitted.

Definition tuple_finMixin n T := Eval hnf in FinMixin (@enumP T n).
Canonical tuple_finType n (T : finType) :=
  Eval hnf in FinType (n.-tuple T) (@tuple_finMixin n T).
*)

Definition finfun_finMixin (aT rT : finType) := 
  [finMixin of @finfun_type aT rT by <:].
Canonical finfun_finType (aT rT : finType) := 
     Eval hnf in FinType (finfun_type aT rT) (finfun_finMixin aT rT).

Lemma card_ffun (aT rT : finType) : #| {ffun aT -> rT} | = #|rT| ^ #|aT|.
Proof. Admitted. (* The proof was an exercise for ch2, see size_all_words *)

Definition eqfun A B (f g : B -> A) : Prop := forall x, f x = g x.
Notation "f1 =1 f2" := (eqfun f1 f2).

Lemma ffunP (aT : finType) rT (f1 f2 : {ffun aT -> rT}) : f1 =1 f2 <-> f1 = f2.
Admitted.

(* This is the context one needs in order to type check the lemma, it's an
extract of bigop.v *)
Section Distributivity.

Import Monoid.Theory.

Variable R : Type.
Variables zero one : R.
Local Notation "0" := zero.
Local Notation "1" := one.
Variable times : Monoid.mul_law 0.
Local Notation "*%M" := times (at level 0).
Local Notation "x * y" := (times x y).
Variable plus : Monoid.add_law 0 *%M.
Local Notation "+%M" := plus (at level 0).
Local Notation "x + y" := (plus x y).

Lemma bigA_distr_bigA (I J : finType) F :
  \big[*%M/1]_(i : I) \big[+%M/0]_(j : J) F i j
  = \big[+%M/0]_(f : {ffun I -> J}) \big[*%M/1]_i F i (f i).
Admitted.

End Distributivity.
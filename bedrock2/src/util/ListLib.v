Require Import Coq.Lists.List.
Import ListNotations.
Require Import compiler.Decidable.
Require Import compiler.util.Tactics.
From Coq Require Import Omega.

Section ListSet.
  Context {E: Type}.
  Context {eeq: DecidableEq E}.

  Definition list_union(A B: list E): list E :=
    fold_left (fun res a => if in_dec eeq a res then res else a :: res) A B.

  Definition list_intersect(A B: list E): list E :=
    fold_left (fun res a => if in_dec eeq a B then a :: res else res) A nil.

  Definition list_diff(A B: list E): list E :=
    fold_left (fun res b => remove eeq b res) B A.

End ListSet.

Definition listUpdate{E: Type}(l: list E)(i: nat)(e: E): list E :=
  firstn i l ++ [e] ++ skipn (S i) l.

Lemma listUpdate_length: forall E i l (e: E),
  i < length l ->
  length (listUpdate l i e) = length l.
Proof.
  induction i; intros.
  - destruct l; simpl in *; [omega|reflexivity].
  - destruct l; simpl in *; [omega|].
    f_equal.
    apply IHi.
    omega.
Qed.

Definition listUpdate_error{E: Type}(l: list E)(i: nat)(e: E): option (list E) :=
  if dec (i < length l) then Some (listUpdate l i e) else None.

Lemma listUpdate_error_length: forall E i l l' (e: E),
  listUpdate_error l i e = Some l' ->
  length l' = length l.
Proof.
  intros. unfold listUpdate_error in H. destruct_one_match_hyp; [|discriminate].
  inversion H. apply listUpdate_length. assumption.
Qed.

Lemma nth_error_listUpdate_error_same: forall i E l l' (e e': E),
  listUpdate_error l i e = Some l' ->
  nth_error l' i = Some e' ->
  e' = e.
Proof.
  induction i; intros.
  - unfold listUpdate_error in H.
    destruct_one_match_hyp; [|discriminate].
    destruct l.
    + simpl in *; omega.
    + unfold listUpdate in H. simpl in *. inversion H. rewrite <- H2 in H0.
      inversion H0. reflexivity.
  - unfold listUpdate_error in H.
    destruct_one_match_hyp; [|discriminate].
    destruct l.
    + simpl in *; omega.
    + unfold listUpdate in H. simpl in *. inversion H. rewrite <- H2 in H0.
      eapply IHi with (l := l).
      2: eassumption.
      unfold listUpdate_error.
      destruct (dec (i < length l)); [reflexivity|omega].
Qed.

Lemma nth_error_firstn: forall E i (l: list E) j,
  j < i ->
  nth_error (firstn i l) j = nth_error l j.
Proof.
  induction i; intros.
  - omega.
  - simpl. destruct l; [reflexivity|].
    destruct j; [reflexivity|].
    simpl.
    apply IHi.
    omega.
Qed.

Lemma nth_error_skipn: forall E i j (l: list E),
  i <= j ->
  nth_error (skipn i l) (j - i) = nth_error l j.
Proof.
  induction i; intros.
  - replace (j - 0) with j by omega. reflexivity.
  - simpl. destruct l.
    * destruct j; simpl; [reflexivity|].
      destruct (j - i); reflexivity.
    * simpl. destruct j; [omega|].
      replace (S j - S i) with (j - i) by omega.
      rewrite IHi by omega.
      reflexivity.
Qed.

Lemma nth_error_listUpdate_error_diff: forall E l l' i j (e: E),
  listUpdate_error l i e = Some l' ->
  j <> i ->
  nth_error l' j = nth_error l j.
Proof.
  intros. unfold listUpdate_error in H.
  destruct_one_match_hyp; [|discriminate].
  assert (j < i \/ i < j < length l \/ length l <= j) as C by omega.
  destruct C as [C|[C|C]].
  - inversion H. clear H. subst l'. unfold listUpdate.
    rewrite nth_error_app1.
    + apply nth_error_firstn. assumption.
    + pose proof (@firstn_length_le _ l i). omega.
  - inversion H. subst l'. unfold listUpdate.
    pose proof (firstn_le_length i l).
    rewrite nth_error_app2 by omega.
    rewrite nth_error_app2 by (simpl; omega).
    rewrite firstn_length_le by omega.
    change (length [e]) with 1.
    replace (j - i -1) with (j - (S i)) by omega.
    apply nth_error_skipn.
    omega.
  - inversion H.
    pose proof (nth_error_None l j) as P.
    destruct P as [_ P]. rewrite P by assumption.
    apply nth_error_None.
    rewrite listUpdate_length; assumption.
Qed.

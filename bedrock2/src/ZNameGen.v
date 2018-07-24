Require Import Coq.Lists.List.
From Coq Require Import Coq.Omega.
Require Import compiler.util.Set.
Require Import compiler.util.List_Set.
Require Import compiler.NameGen.

Definition listmax(l: list nat): nat := fold_right max 0 l.

Lemma listmax_spec: forall l v, In v l -> v <= listmax l.
Proof.
  induction l; intros.
  - simpl in H. contradiction.
  - simpl in *. destruct H.
    + subst. apply Nat.le_max_l. 
    + pose proof (Nat.le_max_r a (listmax l)).
      specialize (IHl v H).
      eapply Nat.le_trans; eassumption.
Qed.

Definition listmaxZ(l: list Z): Z := fold_right Z.max 0%Z l.

Lemma listmaxZ_spec: forall l v, In v l -> (v <= listmaxZ l)%Z.
Proof.
  induction l; intros.
  - simpl in H. contradiction.
  - simpl in *. destruct H.
    + subst. apply Z.le_max_l. 
    + pose proof (Z.le_max_r a (listmaxZ l)).
      specialize (IHl v H).
      eapply Z.le_trans; eassumption.
Qed.

Definition TODO{T: Type}: T. Admitted.

Instance ZNameGen: NameGen Z Z := {|
  freshNameGenState := fun l => (listmaxZ l + 1)%Z;
  genFresh := fun s => (s, (s + 1)%Z);
(*  allFreshVars := fun s => fun x => (s <= x)%Z *)
|}.
  all: apply TODO. (*
  abstract (intros; inversion H; subst; unfold subset; simpl; intuition omega).
  abstract (unfold contains, Function_Set; intros; apply listmaxZ_spec in H; omega).
*)
Defined.

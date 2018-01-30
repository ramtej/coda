open Core_kernel

module type S = sig
  type curve

  module Digest : sig
    type t [@@deriving bin_io]

    module Bits : Bits_intf.S with type t := t

    module Snarkable : functor (Impl : Snark_intf.S) ->
      Impl.Snarkable.Bits.S
      with type Packed.var = Impl.Cvar.t
       and type Packed.value = Impl.Field.t
       and type Unpacked.value = Impl.Field.t
  end

  module Params : sig
    type t = curve array

    val random : max_input_length:int -> t
  end

  module State : sig
    type t

    val create : Params.t ->  t

    val update_bigstring : t -> Bigstring.t -> t

    val update_fold
      : t
      -> (init:(curve * int) -> f:((curve * int) -> bool -> (curve * int)) -> curve * int)
      -> t

    val update_iter
      : t
      -> (f:(bool -> unit) -> unit)
      -> t

    val digest : t -> Digest.t
  end
end

module Make
  : functor
    (Field : Camlsnark.Field_intf.S)
    (Bigint : Camlsnark.Bigint_intf.Extended with type field := Field.t)
    (Curve : Camlsnark.Curves.Edwards.Basic.S with type field := Field.t) ->
    S with type curve := Curve.t
       and type Digest.t = Field.t
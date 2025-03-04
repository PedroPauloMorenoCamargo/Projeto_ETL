(** Representa um pedido na tabela Orders *)

type order = {
  id : int;                  (** Chave primária do pedido *)
  client_id : int;           (** ID do cliente *)
  order_date : string;       (** Data do pedido em formato string (AAAA-MM-DD) *)
  status : string;           (** Status Pending | Complete | Cancelled *)
  origin : string;           (** 'P' para physical, 'O' para online *)
}

(** Representa um item do pedido na tabela OrderItem *)
type order_item = {
  order_id : int;            (** Chave estrangeira para Order.id *)
  product_id : int;          (** Produto que está sendo vendido *)
  quantity : float;          (** Quantidade comprada *)
  price : float;             (** Preço pago naquele momento *)
  tax : float;               (** Imposto em formato percentual. *)
}


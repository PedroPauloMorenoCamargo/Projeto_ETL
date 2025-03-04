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


(** Helper que converte uma lista de strings em um record order. Lança exceção em caso de formato inválido. *)
let order_of_csv_row (row : string list) : order =
  match row with
  | [id_str; client_id_str; order_date_str; status_str; origin_str] ->
      {
        id = int_of_string id_str;
        client_id = int_of_string client_id_str;
        order_date = order_date_str;
        status = status_str;
        origin = origin_str;
      }
  | _ ->
      failwith "Linha de Order CSV inválida: número de colunas incorreto."


(** Helper que converte uma lista de strings em um record order_item. Lança exceção em caso de formato inválido. *)
let order_item_of_csv_row (row : string list) : order_item =
  match row with
  | [order_id_str; product_id_str; quantity_str; price_str; tax_str] ->
      {
        order_id = int_of_string order_id_str;
        product_id = int_of_string product_id_str;
        quantity = float_of_string quantity_str;  
        price = float_of_string price_str;       
        tax = float_of_string tax_str;            
      }
  | _ ->
      failwith "Linha de Order CSV inválida: número de colunas incorreto."

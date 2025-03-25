(** Record que representa uma encomenda na tabela Orders 
  @param id Chave primária do pedido 
  @param cliente_id ID do cliente 
  @param order_date Data da encomenda em formato string (AAAA-MM-DD) 
  @param status Status da encomenda: Pending | Complete | Cancelled
  @param origin 'P' para physical, 'O' para online 
*)
type order = {
  id : int;                  
  client_id : int;
  order_date : string;
  status : string;
  origin : string;
}

(** Record que epresenta um item de um pedido na tabela OrderItem .
  @param order_id Chave estrangeira para uma encomenda.
  @param product_id Produto que está sendo vendido. 
  @param quantity Quantidade comprada.
  @param price Preço do produto.  
  @param tax Imposto em formato percentual.
*)
type order_item = {
  order_id : int;   
  product_id : int; 
  quantity : float;
  price : float;
  tax : float;
}

(** Helper que converte uma lista de strings em um Record {!order}. Lança exceção em caso de formato inválido. 
  @param row Linha do CSV contendo uma encomenda.
  @return Uma encomenda.
*)
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

(** Helper que converte uma lista de strings em um Record {!order_item}. Lança exceção em caso de formato inválido.
  @param row Linha do CSV contendo um item de uma encomenda.
  @return Um item de encomenda.
*)
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

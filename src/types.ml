(** 
  record que representa um pedido na tabela order
  @param id chave primária do pedido 
  @param cliente_id id do cliente 
  @param order_date data do pedido em formato string (AAAA-MM-DD) 
  @param status status do pedido: pending | complete | cancelled
  @param origin 'p' para physical, 'o' para online 
*)
type order = {
  id : int;                  
  client_id : int;
  order_date : string;
  status : string;
  origin : string;
}

(** 
  record que epresenta um item de um pedido na tabela orderitem .
  @param order_id chave estrangeira para um pedido.
  @param product_id produto que está sendo vendido. 
  @param quantity quantidade comprada.
  @param price preço do produto.  
  @param tax imposto em formato percentual.
*)
type order_item = {
  order_id : int;   
  product_id : int; 
  quantity : float;
  price : float;
  tax : float;
}

(** 
  helper que converte uma lista de strings em um record {!Order}. Lança exceção em caso de formato inválido. 
  @param row linha do CSV contendo um pedido.
  @return um pedido.
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

(** 
  helper que converte uma lista de strings em um record {!Order_item}. Lança exceção em caso de formato inválido.
  @param row linha do CSV contendo um item de um pedido.
  @return um item de pedido.
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

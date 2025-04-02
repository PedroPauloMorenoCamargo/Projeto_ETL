(** Importa o arquivo [Types]. *)
open Types

(** 
  filtra os pedidos conforme os parâmetros opcionais de status e origem, se fornecidos.
  @param orders lista de pedidos a ser filtrada.
  @param status parâmetro opcional utilizado para filtrar por status.
  @param origin parâmetro opcional utilizado para filtrar por origem.
  @return lista de pedidos filtrada.
*)
let filter_orders (orders : order list) ~(status : string option) ~(origin : string option) : order list =
  List.filter ( fun ord ->
    let status_value =
      match status with
      | None -> true
      | Some stat -> String.equal stat (ord.status|> String.trim |> String.lowercase_ascii ) 
    in
    let origin_value =
      match origin with
      | None -> true
      | Some ori -> String.equal ori (ord.origin|> String.trim |> String.lowercase_ascii ) 
    in
    status_value && origin_value
  )  orders


(** 
  agrupa os itens que pertencem ao mesmo pedido, retornando uma lista de pedidos com seus respectivos itens.
  @param orders lista de pedidos.
  @param items lista de itens dos pedidos.
  @return lista de tuplas, cada uma contendo um pedido e seus itens.
*)
let join_data (orders : order list) (items : order_item list) : (order * order_item list) list =
  List.map (fun ord ->
    let joined_items = List.filter ( fun it -> it.order_id = ord.id) items in
    (ord, joined_items)
  ) orders


(** 
  calcula o faturamento e o total pago em impostos para uma lista de itens.
  @param items lista de itens de pedidos.
  @return tupla contendo (faturamento, total de impostos pagos).
*)
let acc_amt_tax (items : order_item list) : (float*float) =
  let amount, tax = List.fold_left( fun (amt, tax) item->
    let revenue = item.price *. item.quantity in
    let tax_payed = (item.price *. item.tax *.item.quantity) in
    (amt +. revenue, tax +. tax_payed )

  ) (0.0,0.0) items in
  (amount, tax)



(** 
  para cada pedido, calcula seu faturamento e o total pago em impostos.
  @param data lista de tuplas (pedido, itens do pedido).
  @return lista de tuplas (id do pedido, faturamento, total de impostos pagos).
*)
let merge_amount_taxes (data : (order * order_item list) list) : (int * float * float) list =
  List.map(fun (ord,it) ->
    let total_amt, total_tax = acc_amt_tax it in
    (ord.id, total_amt, total_tax)
  ) data

module StringMap = Map.Make(String)

(** 
  agrupa pedidos por um intervalo de tempo (como ano ou ano-mês) e calcula, para cada grupo,
  a média de faturamento e de impostos pagos.
  Passo-a-passo:
  1. Para cada pedido, extrai um prefixo da data (ex: "2024" ou "2024-08") e calcula o total de faturamento e impostos.
  2. Agrupa os pedidos com o mesmo prefixo de data.
  3. Acumula os valores de faturamento e impostos por grupo.
  4. Calcula as médias dividindo os totais pela quantidade de pedidos em cada grupo.
  @param data lista de tuplas, cada uma contendo um pedido e sua lista de itens.
  @param n número de caracteres iniciais da data usados para o agrupamento 
           (ex: n = 4 agrupa por ano, n = 7 agrupa por ano-mês).
  @return lista de tuplas no formato (data agrupada, faturamento médio, imposto médio pago).
*)

let dates_mean (data : (order * order_item list) list) (n: int) : (string * float * float) list=
  let join_months = List.map( fun (ord, it) ->
    let total_amt, total_tax = acc_amt_tax it in
    (String.sub ord.order_date 0 n, total_amt,total_tax)
  ) data in
  let dictionary = List.fold_left (fun acc_map (date, amt, tax) ->
    let (dic_amt, dic_tax, dic_count) =
    match StringMap.find_opt date acc_map with
      | Some (a, t, n) -> (a, t, n)
      | None -> (0.0, 0.0, 0) in
    StringMap.add date (dic_amt +. amt, dic_tax +. tax, dic_count + 1) acc_map
  ) StringMap.empty join_months in
  StringMap.fold(fun date (amt, tax, count) acc_list->
    let count = float_of_int count in
    (date, amt/.count, tax/.count)::acc_list
  )dictionary []
  

  
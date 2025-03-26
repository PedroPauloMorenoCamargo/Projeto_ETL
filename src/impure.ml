(** importa o arquivo [Types]. *)
open Types

(** 
  lê um arquivo csv e retorna todas as linhas, exceto o cabeçalho.
  @param filename nome do arquivo csv a ser lido.
  @return todas as linhas do csv sem o cabeçalho.
*)
let read_csv (content: string) : string list list =
  let csv_enum = Csv.of_string content in
  let all_rows = Csv.input_all csv_enum in
  List.tl all_rows
  
(** 
  converte os dados do csv em uma lista de registros do tipo {!Order}.
  @param csv_data lista de Linhas do csv
  @return Todos os pedidos.
*)
let load_orders_csv (csv_data: string list list) : order list =
  List.map (fun row -> order_of_csv_row row) csv_data

(** 
  converte os dados do csv em uma lista de registros do tipo {!Order_item}
  @param csv_data lista de Linhas do csv
  @return todos os itens de pedidos
*)
let load_order_items_csv (csv_data: string list list) : order_item list =
  List.map (fun row -> order_item_of_csv_row row) csv_data

(** 
  exibe a mensagem recebida no terminal e armazena o input do usuário normalizado em uma string.
  @param message mensagem a ser exibida no terminal
  @return resposta do usuário
*)
let prompt_input (message : string) : string =
  print_string message;
  flush stdout;
  read_line ()|> String.trim |> String.lowercase_ascii 

(** 
  atribui o tipo de status a ser filtrado
  @param status string com o tipo de filtragem de status
  @return string caso o tipo de  filtragrem esteja entre uma das opções, Vazio caso contrário
*)
let input_status (status : string) : string option  = 
  match  status with
  |"complete" | "pending" | "cancelled" -> Some status
  | _ -> None

(** 
  atribui o tipo de origem a ser filtrada
  @param status string com o tipo de filtragem de origem
  @return string caso o tipo de filtragrem esteja entre uma das opções, Vazio caso contrário
*)
let input_origin (origin : string) : string option  = 
  match origin with
  |"o"|"p" -> Some origin
  | _ -> None


(** 
  realiza uma requisição http para a url fornecida e retorna o conteúdo da resposta como uma string.
  @param url url para a qual será feita a requisição http.
  @return conteúdo da resposta http como string.
*)
let fetch_content_from_http (url : string) : string =
  let buffer = Buffer.create 16384 in
  let connection = Curl.init () in
  Curl.set_url connection url;
  Curl.set_writefunction connection (fun data ->
    Buffer.add_string buffer data;
    String.length data
  );
  Curl.perform connection;
  Curl.cleanup connection;
  Buffer.contents buffer

(** 
  cria uma tabela para o faturamento dos pedidos e preenche a tabela com os valores recebidos
  passo-a-passo: apaga tabela se preciso -> cria tabela nova -> insere as linhas na tabela
  @param connection base de dados já conectada(aberta)
  @param data tupla contendo o id, receita e total pago em imposto
  @return nulo
*)
let load_total_revenue_tax (connection : Sqlite3.db) (data : (int * float * float) list) =
  ignore (Sqlite3.exec connection "DROP TABLE IF EXISTS faturamento_pedidos;");

  let create_table =   "
  CREATE TABLE faturamento_pedidos (
    id INTEGER PRIMARY KEY,
    amount REAL,
    tax REAL
  );
  "  in
  ignore (Sqlite3.exec connection create_table);

  let insert = "
  INSERT INTO faturamento_pedidos (id, amount, tax)
  VALUES (?, ?, ?);
  " in
  let insert_statement = Sqlite3.prepare connection insert in
  List.iter(fun (id, amt, tax) ->
    ignore(Sqlite3.reset insert_statement);
    ignore(Sqlite3.bind_int insert_statement 1 id);
    ignore(Sqlite3.bind_double insert_statement 2 amt);
    ignore(Sqlite3.bind_double insert_statement 3 tax);
    match Sqlite3.step insert_statement with
    | Sqlite3.Rc.DONE -> ()
    | rc -> failwith ("Erro ao inserir no SQLite: " ^ Sqlite3.Rc.to_string rc)
  ) data;
  ignore(Sqlite3.finalize insert_statement);
  ;;

(** 
  cria uma tabela para a média dos pedidos organizada em meses (yyyy-mm) e preenche a tabela com os valores recebidos
  passo-a-passo: apaga tabela se preciso -> cria tabela nova -> insere as linhas na tabela
  @param connection Base de dados já conectada(aberta)
  @param data tupla contendo o mes, receita média por pedido e imposto médio pago por pedido
  @return Nulo
*)
let load_months (connection : Sqlite3.db) (data : (string * float * float) list) =
  ignore (Sqlite3.exec connection "DROP TABLE IF EXISTS média_meses;");

  let create_table =   "
  CREATE TABLE média_meses (
    month TEXT PRIMARY KEY,
    amount REAL,
    tax REAL
  );
  " in
  ignore (Sqlite3.exec connection create_table);

  let insert = "
  INSERT INTO média_meses (month, amount, tax)
  VALUES (?, ?, ?);
  " in
  let insert_statement = Sqlite3.prepare connection insert in
  List.iter(fun (id, amt, tax) ->
    ignore(Sqlite3.reset insert_statement);
    ignore(Sqlite3.bind_text insert_statement 1 id);
    ignore(Sqlite3.bind_double insert_statement 2 amt);
    ignore(Sqlite3.bind_double insert_statement 3 tax);
    match Sqlite3.step insert_statement with
    | Sqlite3.Rc.DONE -> ()
    | rc -> failwith ("Erro ao inserir no SQLite: " ^ Sqlite3.Rc.to_string rc)
  ) data;
  ignore(Sqlite3.finalize insert_statement);
  ;;

(** 
  cria uma tabela para a média dos pedidos organizada em anos (yyyy) e preenche a tabela com os valores recebidos
  passo-a-passo: Apaga tabela se preciso -> Cria tabela nova -> Insere as linhas na tabela
  @param connection base de dados já conectada(aberta)
  @param data tupla contendo o ano, receita média por pedido e imposto médio pago por pedido
  @return nulo
*)
let load_years (connection : Sqlite3.db) (data : (string * float * float) list) =
  ignore (Sqlite3.exec connection "DROP TABLE IF EXISTS média_anos;");
  
  let create_table =   "
  CREATE TABLE média_anos(
    year TEXT PRIMARY KEY,
    amount REAL,
    tax REAL
  );
  " in
  ignore (Sqlite3.exec connection create_table);
  
  let insert = "
  INSERT INTO média_anos (year, amount, tax)
  VALUES (?, ?, ?);
  " in
  let insert_statement = Sqlite3.prepare connection insert in
  List.iter(fun (id, amt, tax) ->
    ignore(Sqlite3.reset insert_statement);
    ignore(Sqlite3.bind_text insert_statement 1 id);
    ignore(Sqlite3.bind_double insert_statement 2 amt);
    ignore(Sqlite3.bind_double insert_statement 3 tax);
    match Sqlite3.step insert_statement with
    | Sqlite3.Rc.DONE -> ()
    | rc -> failwith ("Erro ao inserir no SQLite: " ^ Sqlite3.Rc.to_string rc)
  ) data;
  ignore(Sqlite3.finalize insert_statement);
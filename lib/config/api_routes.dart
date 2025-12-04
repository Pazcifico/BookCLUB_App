import 'api_config.dart';

class ApiRoutes {
  static final String base = ApiConfig.baseUrl;

  // Usuário
  static String signup= "$base/user/api/signup/";
  static String login = "$base/user/api/login/";
  static String logout = "$base/user/api/logout/";
  static String changePassword = "$base/user/api/password/change/";
  static String profile = "$base/user/api/profile/";
  static String resetPassword = "$base/user/api/password/reset/request/";
  static String refresh = "$base/api/token/refresh/";
  static String seguir(int userId) {return "$base/user/api/seguir/$userId/";}



  // Chats
  static String chats = "$base/chat/api/chats/";

  //Grupos
  static String search = "$base/grupo/api/search/";
  static String topicos(int grupoId) {return "$base/grupo/api/grupos/$grupoId/topicos/";}
  static String membros = "$base/grupo/api/membros/selecionar/";
  static String grupoCriar = "$base/grupo/api/criar/";
  static String grupoEditar(int grupoId) {return "$base/grupo/api/editar/$grupoId/";}
  static String grupoSair(int grupoId) {return "$base/grupo/api/sair/$grupoId/";}
  static String grupoEntrar(int grupoId) {return "$base/grupo/api/entrar/$grupoId/";}
  static String mensagens(int topicoId) {return"$base/grupo/api/mensagens/$topicoId/";}
  static String grupoAddMembros(int grupoId) {return "$base/grupo/api/add/membros/$grupoId/";}


  //Resenhas
  static String resenhasListar(int userId) {return "$base/livro/api/resenha/$userId/"; }
  static String resenhasCriar(int livroId) { return "$base/livro/api/resenhas/$livroId/";}



}

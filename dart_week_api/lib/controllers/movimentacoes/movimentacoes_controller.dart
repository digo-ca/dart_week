import 'package:dart_week_api/controllers/movimentacoes/dto/salvar_movimentacao_request.dart';
import 'package:dart_week_api/dart_week_api.dart';
import 'package:dart_week_api/model/usuario_model.dart';
import 'package:dart_week_api/services/movimentacoes_service.dart';
import 'package:intl/intl.dart';

class MovimentacoesController extends ResourceController {
  
  MovimentacoesController(this.context) : service = MovimentacoesService(context);
  final ManagedContext context;
  final MovimentacoesService service;

  @Operation.get('anoMes')
  Future<Response> buscarTodasMovimentacoes() {
    final anoMes = request.path.variables['anoMes'];
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    final UsuarioModel usuario = request.attachments['user'] as UsuarioModel;

    return service
      .buscarMovimentacoes(usuario, anoMes)
      .then((data){
        return data.map((m) => {
          'id': m.id,
          'dataMovimentacao': dateFormat.format(m.dataMovimentacao),
          'descricao': m.descricao,
          'valor': m.valor,
          'categoria': {'id': m.categoria.id, 'nome': m.categoria.nome, 'tipo': m.categoria.tipoCategoria.toString()}
        }).toList();
      }).then((lista) => Response.ok(lista));
  }

  @Operation.get('totalAnoMes')
  Future<Response> recuperarTotalMesAno(@Bind.path('totalAnoMes')String anoMes) async{
    final usuario = request.attachments['user'] as UsuarioModel;
    final resultado = Response.ok(await service.recuperarTotalMovimentacoesPorTipo(usuario, anoMes));

    return resultado;
  }

  @Operation.post()
  Future<Response> salvarMovimento(@Bind.body() SalvarMovimentacaoRequest requestSalvar) async{
    try {
      final validate = requestSalvar.validate();
      if(validate.isNotEmpty){
        return Response.badRequest(body: validate);
      }

      final usuario = request.attachments['user'] as UsuarioModel;

      await service.salvarMovimentacao(usuario, requestSalvar);

      return Response.ok({});
    } catch (e) {
      print(e);
      return Response.serverError(body: {'message': 'Erro ao salvar Movimentacao'});
    }
  }

}
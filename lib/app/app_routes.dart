import 'package:flutter/material.dart';
import 'package:serviceflow/demo_camera_page.dart';
import 'package:serviceflow/demo_signature_page.dart';
import 'package:serviceflow/menu_laboratorio_page.dart';
import 'package:serviceflow/test_icons_page.dart';

import 'modules/splash/presentation/pages/splash_page.dart';
import 'modules/auth/presentation/pages/login_page.dart';
import 'modules/home/presentation/pages/home_page.dart';
import 'modules/clientes/presentation/pages/clientes_list_page.dart';
import 'modules/relatorios/presentation/pages/relatorios_page.dart';
import 'shared/pages/em_desenvolvimento_page.dart';

//importacoes das classes relacionadas aos clientes
import 'modules/clientes/client.repository.dart';
import 'modules/clientes/cliente.service.dart';
import 'modules/clientes/cliente.validation.dart';
import 'modules/clientes/presentation/pages/cliente_form_page.dart';
import 'modules/clientes/cliente.model.dart';

//importacoes das classes relacionados ao servico.model
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'modules/servicos/servico.service.dart';
import 'modules/servicos/servico.validation.dart';
import 'modules/servicos/servico.repository.dart';
import 'modules/servicos/presentation/pages/servicos_list_page.dart';
import 'modules/servicos/presentation/pages/servico_form_page.dart';

//importacoes das classes relacionadas ao tecnico.model
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.model.dart';
import 'package:serviceflow/app/modules/tecnicos/domain/tecnico.service.dart';
import 'package:serviceflow/app/modules/tecnicos/domain/tecnico.validation.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.repository.dart';
import 'modules/tecnicos/presentation/pages/tecnicos_list_page.dart';
import 'modules/tecnicos/presentation/pages/tecnico_form_page.dart';

// Importações das classes relacionadas à Ordem de Serviço
import 'modules/ordens_servico/ordem_servico.repository.dart';
import 'modules/ordens_servico/ordem_servico.validation.dart';
import 'modules/ordens_servico/ordem_servico.service.dart';
import 'modules/ordens_servico/presentation/pages/ordens_servico_list_page.dart';
import 'modules/ordens_servico/presentation/pages/ordem_servico_form_page.dart';
import 'modules/ordens_servico/presentation/pages/ordens_servico_detalhes_page.dart';
import 'modules/dashboard/presentation/pages/dashboard_page.dart';
import 'modules/ordens_servico/ordem_servico.model.dart';

// Importações para listagem de usuários - Teste Laboratório
import 'modules/laboratorio/presentation/pages/laboratorio_page.dart';
import 'modules/laboratorio/presentation/pages/usuarios_list_pages.dart';
import 'modules/usuarios/usuario.repository.dart';
import 'modules/usuarios/usuario.validation.dart';
import 'modules/usuarios/usuario.service.dart';


class AppRoutes {
  static const splash = '/splash';
  static const login = '/auth/login';
  static const home = '/home';
  static const clientes = '/clientes';
  static const ordensServico = '/ordens-servico';
  static const relatorios = '/relatorios';
  static const novaOs = '/nova-os';
  static const dashboard = '/dashboard';
  static const buscar = '/buscar';
  static const pendentes = '/pendentes';
  static const configuracoes = '/configuracoes';
  static const estoque = '/estoque';
  static const fornecedores = '/fornecedores';
  static const menuLab = '/menu-lab';
  static const demoCamera = '/demo-camera';
  static const demoSignature = '/demo-signature';
  static const testIcons = '/test-icons';
  static const servicos = '/servicos';
  static const servicoNovo = '/servico/novo';
  static const servicoEditar = '/servico/editar';
  static const tecnicos = '/tecnicos';
  static const tecnicoNovo = '/tecnico/novo';
  static const tecnicoEditar = '/tecnico/editar';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashPage(),
        login: (_) => const LoginPage(),
        home: (_) => const HomePage(),

        //Rotas concernentes aos clientes
        '/clientes': (_) {
          final repository = ClienteRepository();
          final validation = ClienteValidation(repository);
          final service = ClienteService(validation, repository);
          return ClientesListPage(service);
        },
        // Rota para criação de novo cliente
        '/cliente/novo': (_) {
          final repository = ClienteRepository();
          final validation = ClienteValidation(repository);
          final service = ClienteService(validation, repository);
          return ClienteFormPage(service);
        },
        // Rota para edição de cliente existente extraindo o argumento do envelope
        '/cliente/editar': (context) {
          final repository = ClienteRepository();
          final validation = ClienteValidation(repository);
          final service = ClienteService(validation, repository);
          final cliente = ModalRoute.of(context)!.settings.arguments as Cliente;
          return ClienteFormPage(service, clienteParaEdicao: cliente);
        },

        // Listagem real de Ordens de Serviço (Corrigido para corresponder à HomePage e AppRoutes)
        '/ordens-servico': (_) {
          final repo = OrdemServicoRepository();
          final service = OrdemServicoService(OrdemServicoValidation(repo), repo);
          return OrdensServicoListPage(service);
        },

        // Gerenciamento e detalhes da Ordem de Serviço selecionada (Mantido em kebab-case)
        '/ordem-servico/detalhes': (context) {
          final repo = OrdemServicoRepository();
          final service = OrdemServicoService(OrdemServicoValidation(repo), repo);
          final ordem = ModalRoute.of(context)!.settings.arguments as OrdemServico;
          return OrdemServicoDetalhesPage(service, ordem: ordem);
        },
        
        relatorios: (_) => const RelatoriosPage(),
        // Substituição do placeholder pelo formulário real de O.S.
        novaOs: (_) {
          final repo = OrdemServicoRepository();
          final service = OrdemServicoService(OrdemServicoValidation(repo), repo);
          return OrdemServicoFormPage(service);
        },
        // Vinculação da nova tela de Dashboard Gerencial
        // dashboard: (_) {
        //   final repo = OrdemServicoRepository();
        //   final service = OrdemServicoService(OrdemServicoValidation(repo), repo);
        //   return DashboardPage(service);
        // },
        buscar: (_) => const EmDesenvolvimentoPage(
              titulo: 'Buscar',
              icone: Icons.search,
              cor: Colors.teal,
              descricao: 'Funcionalidade de busca em desenvolvimento',
            ),
        pendentes: (_) => const EmDesenvolvimentoPage(
              titulo: 'Pendências',
              icone: Icons.pending_actions,
              cor: Colors.amber,
              descricao: 'Visualização de pendências em desenvolvimento',
            ),
        configuracoes: (_) => const EmDesenvolvimentoPage(
              titulo: 'Configurações',
              icone: Icons.settings,
              cor: Colors.grey,
              descricao: 'Configurações do sistema em desenvolvimento',
            ),
        estoque: (_) => const EmDesenvolvimentoPage(
              titulo: 'Estoque',
              icone: Icons.inventory,
              cor: Colors.teal,
              descricao: 'Funcionalidade de controle de estoque.\n'
                  'Gerencie produtos, peças e materiais\n'
                  'utilizados nas ordens de serviço.',
            ),
        fornecedores: (_) => const EmDesenvolvimentoPage(
              titulo: 'Fornecedores',
              icone: Icons.business,
              cor: Colors.indigo,
              descricao: 'Funcionalidade para cadastro de fornecedores.\n'
                  'Gerencie contatos e produtos\n'
                  'de seus parceiros comerciais.',
            ),
        menuLab: (context) => const MenuLaboratorioPage(),
        demoCamera: (context) => const DemoCameraPage(),
        demoSignature: (context) => const DemoSignaturePage(),
        testIcons: (context) => const TestIconsPage(),

        //rotas relacionados aos servicos
        '/servicos': (_) {
          final repo = ServicoRepository();
          final service = ServicoService(ServicoValidation(repo), repo);
          return ServicosListPage(service);
        },
        '/servico/novo': (_) {
          final repo = ServicoRepository();
          return ServicoFormPage(ServicoService(ServicoValidation(repo), repo));
        },
        
        // Rota de edição de serviços corrigida
        '/servico/editar': (context) {
          final repository = ServicoRepository();
          final validation = ServicoValidation(repository);
          final service = ServicoService(validation, repository);          
          // Captura e realiza o cast correto do objeto vindo da listagem
          final servico = ModalRoute.of(context)!.settings.arguments as Servico;          
          return ServicoFormPage(service, servicoParaEdicao: servico);
        },
        
        //rotas relacionadas aos técnicos
        '/tecnicos': (_) {
          final repo = TecnicoRepository();
          return TecnicosListPage(TecnicoService(TecnicoValidation(repo), repo));
        },
        '/tecnico/novo': (_) {
          final repo = TecnicoRepository();
          return TecnicoFormPage(TecnicoService(TecnicoValidation(repo), repo));
        },
        '/tecnico/editar': (context) {
          final repo = TecnicoRepository();
          final tecnico = ModalRoute.of(context)!.settings.arguments as Tecnico;
          return TecnicoFormPage(TecnicoService(TecnicoValidation(repo), repo), tecnicoParaEdicao: tecnico);
        },

        //rota para o teste de listagem de usuário
        '/laboratorio': (_) => const LaboratorioPage(),
        // Sub-rota para exibição da listagem de testes de usuários locais
        '/laboratorio/usuarios': (_) {
          final repository = UsuarioRepository();
          final validation = UsuarioValidation(repository);
          final service = UsuarioService(validation, repository);
          return UsuariosListPage(service);
        },
      };
}

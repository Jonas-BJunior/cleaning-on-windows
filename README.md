# Scripts de Privacidade para Windows

Este repositório contém dois scripts PowerShell para ajudar a melhorar a privacidade do Windows, desativando serviços, removendo aplicativos e bloqueando domínios de telemetria. Além disso, inclui um script para verificar se os ajustes foram aplicados corretamente.

---

## Conteúdo

- `privacidade.ps1` — Aplica ajustes de privacidade no Windows.  
- `verifica_privacidade.ps1` — Verifica se os ajustes foram aplicados corretamente.

---

## Requisitos

- Windows 10 ou 11.  
- Permissão de Administrador para executar os scripts.  
- PowerShell 5.1 ou superior (já incluso no Windows 10/11).

---

## Instruções para executar os scripts

### 1. Baixar os scripts

Faça o download dos arquivos `privacidade.ps1` e `verifica_privacidade.ps1` e salve-os na raiz do disco `C:\`.

> **Por que salvar na raiz `C:\`?**  
> Facilita a execução usando caminhos simples e evita problemas de permissão.

---

### 2. Abrir o PowerShell como Administrador

- Clique no menu Iniciar.  
- Digite `PowerShell`.  
- Clique com o botão direito em **Windows PowerShell** e selecione **Executar como administrador**.

---

### 3. Permitir a execução dos scripts temporariamente

No prompt do PowerShell, execute o comando abaixo para liberar a execução dos scripts nesta sessão:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```
Esse script irá aplicar os ajustes de privacidade, como desativar telemetria, parar e desabilitar serviços, remover aplicativos indesejados e bloquear domínios no arquivo hosts.


 ### 4. Executar o script de privacidade
 
 No PowerShell (executando como administrador), execute o comando:

 ```powershell
& "C:\privacidade.ps1"
```

Esse script irá aplicar os ajustes de privacidade, como desativar telemetria, parar e desabilitar serviços, remover aplicativos indesejados e bloquear domínios no arquivo hosts.

 ### 5. Executar o script de verificação

 Para confirmar se as configurações foram aplicadas corretamente, execute o comando:

 ```powershell
& "C:\verifica_privacidade.ps1"
```
 
Ele exibirá o status das configurações de privacidade, serviços e bloqueios de domínios no sistema.


### Dicas e cuidados

- Sempre execute os scripts como Administrador para garantir as permissões necessárias.  
- Recomendamos criar um ponto de restauração do sistema antes de aplicar os ajustes.  
- O script `privacidade.ps1` remove aplicativos nativos do Windows, que podem ser difíceis de restaurar sem reinstalar o sistema.

### Perguntas frequentes

**Posso executar os scripts em qualquer pasta?**  
Sim, mas recomendamos salvar na raiz `C:\` para facilitar a execução e evitar problemas de permissão.

**Preciso alterar a política de execução permanentemente?**  
Não. O comando `Set-ExecutionPolicy` usado aqui altera a política apenas para a sessão atual do PowerShell.

**O script de verificação faz alguma alteração no sistema?**  
Não. Ele apenas lê as configurações e exibe o status para confirmar que as mudanças foram aplicadas.

---

Obrigado por usar estes scripts! Sua privacidade no Windows agradece. 😊

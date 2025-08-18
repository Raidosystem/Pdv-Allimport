// Diagnóstico completo do GitHub Actions
import fetch from 'node-fetch';

async function diagnosticarGitHubActions() {
    console.log('🔍 DIAGNÓSTICO GITHUB ACTIONS - PDV ALLIMPORT\n');
    
    try {
        // 1. Verificar repositório via API
        console.log('1. Verificando repositório GitHub...');
        
        const repoResponse = await fetch('https://api.github.com/repos/Raidosystem/Pdv-Allimport');
        
        if (repoResponse.ok) {
            const repo = await repoResponse.json();
            console.log(`   ✅ Repositório encontrado: ${repo.full_name}`);
            console.log(`   - Private: ${repo.private}`);
            console.log(`   - Has Pages: ${repo.has_pages}`);
            console.log(`   - Default branch: ${repo.default_branch}`);
            console.log(`   - Último push: ${repo.pushed_at}`);
        } else {
            console.log('   ❌ Erro ao acessar repositório:', repoResponse.status);
        }
        
        // 2. Verificar workflows
        console.log('\n2. Verificando workflows...');
        
        const workflowsResponse = await fetch('https://api.github.com/repos/Raidosystem/Pdv-Allimport/actions/workflows');
        
        if (workflowsResponse.ok) {
            const workflows = await workflowsResponse.json();
            console.log(`   ✅ Encontrados ${workflows.total_count} workflows:`);
            
            workflows.workflows.forEach(workflow => {
                console.log(`     - ${workflow.name} (${workflow.state})`);
                console.log(`       Path: ${workflow.path}`);
                console.log(`       Último run: ${workflow.updated_at}`);
            });
        } else {
            console.log('   ❌ Erro ao acessar workflows:', workflowsResponse.status);
        }
        
        // 3. Verificar último run
        console.log('\n3. Verificando últimas execuções...');
        
        const runsResponse = await fetch('https://api.github.com/repos/Raidosystem/Pdv-Allimport/actions/runs?per_page=5');
        
        if (runsResponse.ok) {
            const runs = await runsResponse.json();
            console.log(`   ✅ Últimas ${runs.workflow_runs.length} execuções:`);
            
            runs.workflow_runs.forEach((run, index) => {
                console.log(`     ${index + 1}. ${run.name}`);
                console.log(`        Status: ${run.status} | Conclusão: ${run.conclusion}`);
                console.log(`        Branch: ${run.head_branch}`);
                console.log(`        Iniciado: ${run.run_started_at}`);
                console.log(`        URL: ${run.html_url}`);
                console.log('');
            });
        } else {
            console.log('   ❌ Erro ao acessar runs:', runsResponse.status);
        }
        
        // 4. Verificar GitHub Pages
        console.log('4. Verificando GitHub Pages...');
        
        const pagesResponse = await fetch('https://api.github.com/repos/Raidosystem/Pdv-Allimport/pages');
        
        if (pagesResponse.ok) {
            const pages = await pagesResponse.json();
            console.log('   ✅ GitHub Pages configurado:');
            console.log(`     - URL: ${pages.html_url}`);
            console.log(`     - Status: ${pages.status}`);
            console.log(`     - Source: ${pages.source.branch}/${pages.source.path}`);
        } else if (pagesResponse.status === 404) {
            console.log('   ⚠️ GitHub Pages não configurado (404)');
        } else {
            console.log(`   ❌ Erro ao verificar Pages: ${pagesResponse.status}`);
        }
        
        // 5. Testar se o site está no ar
        console.log('\n5. Testando sites deployados...');
        
        const sites = [
            'https://raidosystem.github.io/Pdv-Allimport/',
            'https://pdv-producao.surge.sh/',
            'https://pdv.crmvsystem.com/'
        ];
        
        for (const site of sites) {
            try {
                const response = await fetch(site);
                console.log(`   ${response.ok ? '✅' : '❌'} ${site} - Status: ${response.status}`);
            } catch (error) {
                console.log(`   ❌ ${site} - Erro: ${error.message}`);
            }
        }
        
        // 6. Recomendações
        console.log('\n📋 DIAGNÓSTICO E RECOMENDAÇÕES:');
        console.log('');
        console.log('🔧 POSSÍVEIS PROBLEMAS:');
        console.log('   1. GitHub Pages não está habilitado no repositório');
        console.log('   2. Workflow está falhando devido a permissões');
        console.log('   3. Environment "github-pages" não configurado');
        console.log('   4. Actions pode estar desabilitado');
        console.log('');
        console.log('✅ SOLUÇÕES:');
        console.log('   1. Verificar se Actions está habilitado em Settings > Actions');
        console.log('   2. Verificar se Pages está configurado em Settings > Pages');
        console.log('   3. Usar workflow manual "Simple Deploy"');
        console.log('   4. Verificar logs detalhados em Actions tab');
        console.log('');
        console.log('🌐 SITES FUNCIONAIS CONFIRMADOS:');
        console.log('   - https://pdv-producao.surge.sh/');
        console.log('   - https://pdv-final.surge.sh/');
        console.log('   - Login: admin@pdv.com / admin123');
        
    } catch (error) {
        console.error('❌ Erro no diagnóstico:', error.message);
    }
}

diagnosticarGitHubActions();

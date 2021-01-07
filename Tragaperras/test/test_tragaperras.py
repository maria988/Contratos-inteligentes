
import pytest

import brownie
PREMIO1 = 10
PREMIO2 = 30
NVECES = 3
VAR1 = 2
VAR2 = 4
PRECIO = 10
BENEFICIOS_MAQUINA = 50
BENEFICIOS_LOCAL = 25
PORCENTAJE_MAQUINA = 25
PREMIO12 = 5
PREMIO22 = 20
@pytest.fixture
def tragaperras_contract(tragaperras, accounts):
    yield tragaperras.deploy(accounts[1],PREMIO1,PREMIO2,NVECES,VAR1,VAR2,PRECIO,BENEFICIOS_MAQUINA,BENEFICIOS_LOCAL,PORCENTAJE_MAQUINA,{'from': accounts[0]})

def test_inicial(tragaperras_contract,accounts):
    assert tragaperras_contract.empresa() == accounts[0]
    assert tragaperras_contract.socio() == accounts[1]
    assert tragaperras_contract.premio1() == PREMIO1
    assert tragaperras_contract.premio2() == PREMIO2
    assert tragaperras_contract.n_veces() == NVECES
    assert tragaperras_contract.variacion1() == VAR1
    assert tragaperras_contract.variacion2() == VAR2
    assert tragaperras_contract.precio() == PRECIO
    assert tragaperras_contract.benef_maquina() ==BENEFICIOS_MAQUINA
    assert tragaperras_contract.benef_local() == BENEFICIOS_LOCAL
    assert tragaperras_contract.porc_maq() == PORCENTAJE_MAQUINA

def test_event(tragaperras_contract,accounts):
    tx1 = tragaperras_contract.echarmoneda({'from':accounts[2],'value':PRECIO})
    tx2 = tragaperras_contract.echarmoneda({'from':accounts[3],'value':PRECIO})
    assert tragaperras_contract.premio({'from':accounts[2]}) == PRECIO *2* PREMIO1 /100
    tx3 = tragaperras_contract.echarmoneda({'from':accounts[4],'value':PRECIO})
    
    assert len(tx1.events) ==1
    assert tx1.events[0]['jugador'] == accounts[2]
    assert tx1.events[0]['texto'] == "Sigue jugando"
    assert len(tx2.events)== 1
    assert tx2.events[0]['premio'] == 0
    assert len(tx3.events) == 1
    assert tx3.events[0]['jugador']==accounts[4]
    assert tx3.events[0]['texto'] == "Ha ganado"
    assert tx3.events[0]['premio'] == PRECIO * 3* PREMIO1 /100
    
def test_failed_transactions(tragaperras_contract, accounts):
    
    with brownie.reverts("Precio exacto"):
        tragaperras_contract.echarmoneda({'from':accounts[2],'value':5})
    
    with brownie.reverts("Empresa"):
        tragaperras_contract.sacardinero({'from':accounts[3]})
        
    with brownie.reverts("Empresa"):
        tragaperras_contract.cambiarpremio(PREMIO12,PREMIO22,{'from':accounts[3]})
    
    with brownie.reverts("Distintos premios"):
        tragaperras_contract.cambiarpremio(PREMIO1,PREMIO22,{'from':accounts[0]})
    
    with brownie.reverts("Empresa"):
        tragaperras_contract.cambiarvariaciones(VAR2,VAR1,{'from':accounts[3]})
    
    with brownie.reverts("Distintas variaciones"):
        tragaperras_contract.cambiarvariaciones(VAR2,VAR2,{'from':accounts[0]})
    

import pytest

import brownie
PREMIO = 10
PRECIO = 10
BENEFICIOS_MAQUINA = 50
BENEFICIOS_LOCAL = 25
PORCENTAJE_MAQUINA = 25
INITIAL_VALUE = 100
PREMIO12 = 5
PREMIO22 = 20
@pytest.fixture
def tragaperras2_contract(tragaperras2, accounts):
    yield tragaperras2.deploy(accounts[1],PREMIO,PRECIO,BENEFICIOS_MAQUINA,BENEFICIOS_LOCAL,PORCENTAJE_MAQUINA,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(tragaperras2_contract,accounts):
    assert tragaperras2_contract.empresa() == accounts[0]
    assert tragaperras2_contract.socio() == accounts[1]
    assert tragaperras2_contract.precio() == PRECIO
    assert tragaperras2_contract.benef_maquina() ==BENEFICIOS_MAQUINA
    assert tragaperras2_contract.benef_local() == BENEFICIOS_LOCAL
    assert tragaperras2_contract.porc_maq() == PORCENTAJE_MAQUINA
    assert tragaperras2_contract.balance() == INITIAL_VALUE

def test_event(tragaperras2_contract,accounts):
    tragaperras2_contract.echarmoneda({'from':accounts[3],'value':PRECIO})
    tx1 = tragaperras2_contract.ganado(False,{'from':accounts[0]})
    assert tragaperras2_contract.funpremio({'from':accounts[2]}) == ((PRECIO +INITIAL_VALUE)* PREMIO) /100
    tragaperras2_contract.echarmoneda({'from':accounts[4],'value':PRECIO})
    tx2 = tragaperras2_contract.ganado(True,{'from':accounts[0]})
    
    assert len(tx1.events) ==1
    assert tx1.events[0]['jugador'] == accounts[3]
    assert tx1.events[0]['texto'] == "Sigue jugando"
    assert len(tx2.events) == 1
    assert tx2.events[0]['jugador']==accounts[4]
    assert tx2.events[0]['texto'] == "Ha ganado"
    assert tx2.events[0]['premio'] == ((PRECIO * 2)+INITIAL_VALUE)* PREMIO /100
    
def test_failed_transactions(tragaperras2_contract, accounts):
    
    with brownie.reverts("Precio exacto"):
        tragaperras2_contract.echarmoneda({'from':accounts[2],'value':5})
    
    with brownie.reverts("Empresa"):
        tragaperras2_contract.sacardinero({'from':accounts[3]})
        
    with brownie.reverts("Empresa"):
        tragaperras2_contract.cambiarpremio(PREMIO,{'from':accounts[3]})
    
    with brownie.reverts("Distinto premio"):
        tragaperras2_contract.cambiarpremio(PREMIO,{'from':accounts[0]})
    
    with brownie.reverts("Empresa"):
        tragaperras2_contract.ganado(False,{'from':accounts[2]})
        
    with brownie.reverts("Jugando"):
        tragaperras2_contract.ganado(False,{'from':accounts[0]})
        
    tragaperras2_contract.echarmoneda({'from':accounts[3],'value':PRECIO})
    
    with brownie.reverts("No jugando"):
        tragaperras2_contract.echarmoneda({'from':accounts[2],'value':PRECIO})


import pytest

import brownie
import time
PRESUPUESTO = 20000
TIEMPO_OBRA = 2
MES = 1
INICIO = 4
ALQUILER = 300

@pytest.fixture
def obra_contract(obracasa, accounts):
    yield obracasa.deploy(PRESUPUESTO,TIEMPO_OBRA,INICIO,accounts[1],MES,{'from': accounts[0]})

def test_inicial(obra_contract,accounts):
    assert obra_contract.constructora() == accounts[0]
    assert obra_contract.cliente() == accounts[1]
    assert obra_contract.tiempo_obra() == TIEMPO_OBRA
    assert obra_contract.presupuesto() == PRESUPUESTO
    assert obra_contract.mes() == MES
    
    
def test_events(obra_contract,accounts):
    obra_contract.pagarobra(ALQUILER,{'from':accounts[1],'value':PRESUPUESTO})
    time.sleep(4)
    tx1 = obra_contract.cobraralquiler({'from':accounts[1]})
    
    assert len(tx1.events)==1
    assert tx1.events[0]['emisor'] == accounts[0]
    assert tx1.events[0]['receptor'] == accounts[1]
    assert tx1.events[0]['valor'] == ALQUILER
    
    obra_contract.finobra({'from':accounts[0]})
    tx2 = obra_contract.findelcontrato({'from':accounts[1]})
    assert len(tx2.events) == 1
    assert tx2.events[0]['emisor'] == accounts[1]
    assert tx2.events[0]['receptor'] == accounts[0]
    assert tx2.events[0]['valor'] == 19700
    
    
def test_failed_transactions(obra_contract, accounts):
    
    with brownie.reverts("Ha empezado"):
        obra_contract.cobraralquiler({'from':accounts[0]})
        
    with brownie.reverts("Cliente"):
        obra_contract.pagarobra(ALQUILER,{'from':accounts[0],'value':PRESUPUESTO})
    
    with brownie.reverts("Precio exacto"):
        obra_contract.pagarobra(ALQUILER,{'from':accounts[1],'value':PRESUPUESTO-1})
    
    with brownie.reverts("Empezada"):
        obra_contract.finobra({'from':accounts[0]})
        
    obra_contract.pagarobra(ALQUILER,{'from':accounts[1],'value':PRESUPUESTO})
    with brownie.reverts("Fuera del tiempo estimado"):
        obra_contract.cobraralquiler({'from':accounts[0]})
        
    with brownie.reverts("No ha empezado"):
        obra_contract.pagarobra(ALQUILER,{'from':accounts[1],'value':PRESUPUESTO})
    
    with brownie.reverts("Precio exacto"):
        obra_contract.pagoalquiler({'from':accounts[0],'value':ALQUILER - 1})
        
    with brownie.reverts("Constructora"):
        obra_contract.pagoalquiler({'from':accounts[1],'value':ALQUILER}) 
    
    
    
    with brownie.reverts("Constructora"):
        obra_contract.finobra({'from':accounts[1]})  
        
    with brownie.reverts("Cliente"):
        obra_contract.findelcontrato({'from':accounts[0]})
    
    with brownie.reverts("Terminada"):
        obra_contract.findelcontrato({'from':accounts[1]})

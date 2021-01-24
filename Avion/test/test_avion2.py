
import pytest

import brownie
import time

ASIENTOS = 2

PRECIO = 100
PORC = 5
TIEMPO_SALIDA = 1


@pytest.fixture
def avion2_contract(avion2, accounts):
    yield avion2.deploy(ASIENTOS,PRECIO,PORC,TIEMPO_SALIDA,{'from': accounts[0]})

def test_inicial(avion2_contract,accounts):
    assert avion2_contract.asientos() == ASIENTOS
    assert avion2_contract.aerolinea() == accounts[0]
    assert avion2_contract.precio() == PRECIO
    assert avion2_contract.porc_a_devolver() == PORC
    
def test_events(avion2_contract, accounts):
    tx1 = avion2_contract.comprar(1,{'from':accounts[1],'value':PRECIO})
    
    assert len(tx1.events) == 1
    assert tx1.events[0]['comprador'] == accounts[1]
    assert tx1.events[0]['vendedor']== accounts[0]
    assert tx1.events[0]['valor']== 100
    
    time.sleep(20)
    avion2_contract.asalido({'from':accounts[0]})
    tx2 = avion2_contract.devolucionalosclientes({'from':accounts[1]})
    assert len(tx2.events) == 1
    assert tx2.events[0]['receptor'] == accounts[1]
    assert tx2.events[0]['emisor']== accounts[0]
    assert tx2.events[0]['value']== avion2_contract.dinero()
    

def test_failed_transactions(avion2_contract, accounts):
    
    with brownie.reverts("Menos de 4"):
        avion2_contract.comprar(4,{'from': accounts[3],'value':400})
    
    with brownie.reverts("Suficientes asientos"):
        avion2_contract.comprar(3,{'from': accounts[2],'value':1000})
        
    with brownie.reverts("Precio exacto"):
        avion2_contract.comprar(1,{'from': accounts[2],'value':50})
        
    avion2_contract.comprar(1,{'from':accounts[3],'value':100})
    with brownie.reverts("Aerolinea"):
        avion2_contract.asalido({'from': accounts[1]})
    
    with brownie.reverts("Ha salido"):
        avion2_contract.devolucionalosclientes({'from': accounts[1]})
        
    avion2_contract.asalido({'from': accounts[0]})
    
    with brownie.reverts("No ha salido"):
        avion2_contract.asalido({'from': accounts[0]})

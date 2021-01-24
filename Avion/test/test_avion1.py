
import pytest

import brownie
import time

ASIENTOS = 2

PRECIO = 100
PORC = 5
TIEMPO_SALIDA = 1


@pytest.fixture
def avion1_contract(avion1, accounts):
    yield avion1.deploy(ASIENTOS,PRECIO,PORC,TIEMPO_SALIDA,{'from': accounts[0]})

def test_inicial(avion1_contract,accounts):
    assert avion1_contract.asientos() == ASIENTOS
    assert avion1_contract.aerolinea() == accounts[0]
    assert avion1_contract.precio() == PRECIO
    assert avion1_contract.porc_a_devolver() == PORC
    
def test_events(avion1_contract, accounts):
    tx1 = avion1_contract.comprar(1,{'from':accounts[1],'value':PRECIO})
    
    assert len(tx1.events) == 1
    assert tx1.events[0]['comprador'] == accounts[1]
    assert tx1.events[0]['vendedor']== accounts[0]
    assert tx1.events[0]['valor']== 100
    
    time.sleep(20)
    avion1_contract.asalido({'from':accounts[0]})
    tx2 = avion1_contract.devolucionalosclientes({'from':accounts[1]})
    assert len(tx2.events) == 1
    assert tx2.events[0]['receptor'] == accounts[1]
    assert tx2.events[0]['emisor']== accounts[0]
    assert tx2.events[0]['value']== avion1_contract.dinero()
    

def test_failed_transactions(avion1_contract, accounts):
    
    with brownie.reverts("Menos de 4"):
        avion1_contract.comprar(4,{'from': accounts[3],'value':400})
    
    with brownie.reverts("Suficientes asientos"):
        avion1_contract.comprar(3,{'from': accounts[2],'value':1000})
        
    with brownie.reverts("Precio exacto"):
        avion1_contract.comprar(1,{'from': accounts[2],'value':50})
        
    avion1_contract.comprar(1,{'from':accounts[3],'value':100})
    with brownie.reverts("Aerolinea"):
        avion1_contract.asalido({'from': accounts[1]})
    
    with brownie.reverts("Ha salido"):
        avion1_contract.devolucionalosclientes({'from': accounts[1]})
        
    avion1_contract.asalido({'from': accounts[0]})
    
    with brownie.reverts("No ha salido"):
        avion1_contract.asalido({'from': accounts[0]})

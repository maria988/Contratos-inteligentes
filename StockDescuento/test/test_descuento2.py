
import pytest

import brownie
import time
STOCK = 50
PRECIO = 20
INICIO = 3
DURACION = 5
PRECIODESCUENTO = 10
@pytest.fixture
def descuento2_contract(descuento2, accounts):
    yield descuento2.deploy(STOCK,PRECIO,INICIO,DURACION,PRECIODESCUENTO,{'from': accounts[0]})

def test_inicial(descuento2_contract,accounts):
    assert descuento2_contract.vendedor() == accounts[0]
    assert descuento2_contract.precio() == PRECIO
    assert descuento2_contract.stock() == STOCK
    assert descuento2_contract.pdescuento() == PRECIODESCUENTO

def test_compra(descuento2_contract,accounts):
    descuento2_contract.comprar({'from':accounts[1],'value':20})
    assert descuento2_contract.stock() == 49 
    time.sleep(5)
    descuento2_contract.comprar({'from':accounts[2],'value':20})
    assert descuento2_contract.stock() == 47
    time.sleep(6)
    descuento2_contract.comprar({'from':accounts[1],'value':20})
    assert descuento2_contract.stock() == 46
    descuento2_contract.terminar({'from':accounts[0]})
    
    
def test_failed_transactions(descuento2_contract, accounts):
    
    with brownie.reverts("Precio adecuado"):
        descuento2_contract.comprar({'from':accounts[1],'value':10})
    
    time.sleep(5)
    descuento2_contract.comprar({'from':accounts[3],'value':250}) 
    with brownie.reverts("Hay stock suficiente"):
        descuento2_contract.comprar({'from':accounts[3],'value':500})
    descuento2_contract.comprar({'from':accounts[3],'value':250})
    with brownie.reverts("Hay stock"):
        descuento2_contract.comprar({'from':accounts[3],'value':100})
    with brownie.reverts("Vendedor"):
        descuento2_contract.terminar({'from':accounts[1]})

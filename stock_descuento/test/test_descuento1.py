
import pytest

import brownie
import time
STOCK = 50
PRECIO = 20
INICIO = 3
DURACION = 5
PRECIODESCUENTO = 10
@pytest.fixture
def descuento1_contract(Descuento1, accounts):
    yield Descuento1.deploy(STOCK,PRECIO,INICIO,DURACION,PRECIODESCUENTO,{'from': accounts[0]})

def test_inicial(descuento1_contract,accounts):
    assert descuento1_contract.vendedor() == accounts[0]
    assert descuento1_contract.precio() == PRECIO
    assert descuento1_contract.stock() == STOCK
    assert descuento1_contract.pdescuento() == PRECIODESCUENTO

def test_compra(descuento1_contract,accounts):
    descuento1_contract.comprar({'from':accounts[1],'value':20})
    assert descuento1_contract.stock() == 49 
    time.sleep(5)
    descuento1_contract.comprar({'from':accounts[2],'value':20})
    assert descuento1_contract.stock() == 47
    time.sleep(6)
    descuento1_contract.comprar({'from':accounts[1],'value':20})
    assert descuento1_contract.stock() == 46
    descuento1_contract.terminar({'from':accounts[0]})
    
    
def test_failed_transactions(descuento1_contract, accounts):
    
    with brownie.reverts("Precio adecuado"):
        descuento1_contract.comprar({'from':accounts[1],'value':10})
    
    time.sleep(5)
    with brownie.reverts("Precio minimo"):
        descuento1_contract.comprar({'from':accounts[1],'value':5})
        
    descuento1_contract.comprar({'from':accounts[3],'value':500})
    with brownie.reverts("Hay stock"):
        descuento1_contract.comprar({'from':accounts[3],'value':100})
    with brownie.reverts("Vendedor"):
        descuento1_contract.terminar({'from':accounts[1]})

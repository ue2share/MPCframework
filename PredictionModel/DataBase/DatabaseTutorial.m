dbfile = fullfile(pwd,'tutorial.db');

conn = sqlite(dbfile, 'create');

createInventoryTable = ['create table inventoryTable ' ...
    '(productNumber NUMERIC, Quantity NUMERIC, ' ...
    'Price NUMERIC, inventoryDate VARCHAR)'];
exec(conn,createInventoryTable)

createSuppliers = ['create table suppliers ' ...
    '(SupplierNumber NUMERIC, SupplierName varchar(50), ' ...
    'City varchar(20), Country varchar(20), ' ...
    'FaxNumber varchar(20))'];
exec(conn,createSuppliers)

createSalesVolume = ['create table salesVolume ' ...
    '(StockNumber NUMERIC, January NUMERIC, ' ...
    'February NUMERIC, March NUMERIC, April NUMERIC, ' ...
    'May NUMERIC, June NUMERIC, July NUMERIC, ' ...
    'August NUMERIC, September NUMERIC, October NUMERIC, ' ...
    'November NUMERIC, December NUMERIC)'];
exec(conn,createSalesVolume)

createProductTable = ['create table productTable ' ...
    '(productNumber NUMERIC, stockNumber NUMERIC, ' ...
    'supplierNumber NUMERIC, unitCost NUMERIC, ' ...
    'productDescription varchar(20))'];
exec(conn,createProductTable)

clear createInventoryTable createSuppliers createSalesVolume ...
    createProductTable


load('sqliteworkflowdata.mat')

insert(conn,'inventoryTable', ...
    {'productNumber','Quantity','Price','inventoryDate'},CinvTable)

insert(conn,'suppliers', ...
    {'SupplierNumber','SupplierName','City','Country','FaxNumber'}, ...
    Csuppliers)

insert(conn,'salesVolume', ...
    {'StockNumber','January','February','March','April','May','June', ...
    'July','August','September','October','November','December'}, ...
    CsalesVol)

insert(conn,'productTable', ...
    {'productNumber','stockNumber','supplierNumber','unitCost', ...
    'productDescription'},CprodTable)

clear CinvTable Csuppliers CsalesVol CprodTable

close(conn)

clear conn

conn = sqlite('tutorial.db','readonly');

%% Import Data into MATLAB
inventoryTable_data = fetch(conn,'SELECT * FROM inventoryTable');

suppliers_data = fetch(conn,'SELECT * FROM suppliers');

salesVolume_data = fetch(conn,'SELECT * FROM salesVolume');

productTable_data = fetch(conn,'SELECT * FROM productTable');
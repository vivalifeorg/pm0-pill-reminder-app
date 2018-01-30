#runs in python3

from collections import defaultdict

def cleanedProductName(name):
  if name == "Wilate - von Willebrand Factor/Coagulation Factor VIII Complex (Human)":
    return "Wilate"
  
  return name.title().replace(' Fs',' FS') #they don't have a great capilziation story here...

class ProductInfo:
  def __init__(self, ndcProductCode, name, startDate, producer):
    self.ndcProductCode = ndcProductCode
    self.productName = cleanedProductName(name) #fixes capitalization/wilate
    self.startDate = startDate
    self.producer = producer

class PackageInfo:
  def __init__(self, ndcProductCode, ndcPackageCode, packageDescription):
    self.ndcProductCode = ndcProductCode
    self.ndcPackageCode = ndcPackageCode
    self.packageDescription = packageDescription

class Package:
  def __init__(self, productInfo, packageInfo):
    self.ndcProductCode = productInfo.ndcProductCode
    self.productName = productInfo.productName
    self.startDate = productInfo.startDate
    self.producer = productInfo.producer
    self.ndcPackageCode = packageInfo.ndcPackageCode
    self.packageDescription = packageInfo.packageDescription

def package_list():
  packages = []
  with open("package.txt") as f:
     for line in f.readlines():
       tokens = line.split('\t')
       packages.append(PackageInfo(tokens[1].strip(),tokens[2].strip(),tokens[3].strip()))
  return packages

def product_list():
  products = []
  with open("all_products.tsv") as f:
     for line in f.readlines():
       tokens = line.split('\t')
       print(line)
       print(tokens)
       products.append(ProductInfo( tokens[1].strip(), tokens[2].strip(), tokens[3].strip(), tokens[4].strip()))
  return products
 
productsByProductCode = {}
for product in product_list():
  productsByProductCode[product.ndcProductCode] = product

packagesByProductCode = defaultdict(list)
packagesByProductName = defaultdict(list)
for packageInfo in package_list():
  product = productsByProductCode.get(packageInfo.ndcProductCode)
  if not product is None:
    package = Package(product, packageInfo)
    packagesByProductCode[package.ndcProductCode].append(package)
    packagesByProductName[package.productName].append(package)


def potencyLookup(pkgCode):
  return 0

productNames = []
productNameMaker = {}
for product in product_list():
  productNameMaker[product.productName] = product
productNames = list(productNameMaker.keys())
productNames.sort()



print()
print("let products = [")
for productName in productNames:
  print('  Product(productName:"{productName}", availablePackagingOptions: ['.format(productName=productName))
  for package in packagesByProductName[productName]:
    nominalPotency = potencyLookup(package.ndcPackageCode)
    print('    ProductPackaging(productName: "{productName}", ndcPackageCode: "{ndcPackageCode}", packageDescription:"{packageDescription}", nominalPotency:{nominalPotency}),'.format(productName=package.productName,ndcPackageCode=package.ndcPackageCode,packageDescription=package.packageDescription,nominalPotency=nominalPotency))
  print("  ]),\n")
print("]")
    



import SwiftUI
import Firebase
import Stripe
import MapKit

// Modèle de Produit Étendu
struct WorldProduct: Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let price: Double
    let description: String
    let imageURL: String
    let category: ProductCategory
    let nutritionalInfo: NutritionalInfo
    var rating: Double
    
    enum ProductCategory {
        case candy
        case dessert
        case drink
    }
    
    struct NutritionalInfo {
        let calories: Int
        let sugar: Double
        let allergens: [String]
    }
}

// Extension pour la localisation des produits
extension WorldProduct {
    var localizedCategory: String {
        switch category {
        case .candy: return "Bonbons"
        case .dessert: return "Gâteaux"
        case .drink: return "Boissons"
        }
    }
}

// Gestionnaire de Catalogue
class ProductCatalogManager: ObservableObject {
    @Published var products: [WorldProduct] = []
    @Published var categories: [WorldProduct.ProductCategory] = [.candy, .dessert, .drink]
    
    func fetchProducts(for category: WorldProduct.ProductCategory) -> [WorldProduct] {
        return products.filter { $0.category == category }
    }
    
    func fetchProductsByCountry(_ country: String) -> [WorldProduct] {
        return products.filter { $0.country == country }
    }
}

// Vue de Catalogue Mondial
struct WorldCatalogView: View {
    @StateObject private var catalogManager = ProductCatalogManager()
    @State private var selectedCategory: WorldProduct.ProductCategory = .candy
    
    var body: some View {
        NavigationView {
            VStack {
                // Sélecteur de Catégorie
                Picker("Catégorie", selection: $selectedCategory) {
                    Text("Bonbons").tag(WorldProduct.ProductCategory.candy)
                    Text("Gâteaux").tag(WorldProduct.ProductCategory.dessert)
                    Text("Boissons").tag(WorldProduct.ProductCategory.drink)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Liste des Produits par Catégorie
                List {
                    ForEach(catalogManager.fetchProducts(for: selectedCategory)) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            ProductRowView(product: product)
                        }
                    }
                }
                .navigationTitle("Produits du Monde")
            }
        }
    }
}

// Vue Détaillée du Produit
struct ProductDetailView: View {
    let product: WorldProduct
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Image du Produit
                AsyncImage(url: URL(string: product.imageURL)) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .aspectRatio(contentMode: .fit)
                .frame(height: 300)
                
                // Informations Principales
                Text(product.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Origine: \(product.country)")
                    .font(.subtitle)
                
                // Informations Nutritionnelles
                Section(header: Text("Informations Nutritionnelles")) {
                    Text("Calories: \(product.nutritionalInfo.calories)")
                    Text("Sucre: \(String(format: "%.1f", product.nutritionalInfo.sugar))g")
                    
                    if !product.nutritionalInfo.allergens.isEmpty {
                        Text("Allergènes: \(product.nutritionalInfo.allergens.joined(separator: ", "))")
                            .foregroundColor(.red)
                    }
                }
                
                // Bouton d'Ajout au Panier
                Button(action: {
                    // Logique d'ajout au panier
                }) {
                    Text("Ajouter au Panier")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

// Vue Ligne de Produit
struct ProductRowView: View {
    let product: WorldProduct
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: product.imageURL)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 80, height: 80)
            .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                Text(product.country)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(String(format: "%.2f", product.price)) €")
                .fontWeight(.bold)
        }
    }
}

// Exemple de Données Initiales
extension ProductCatalogManager {
    func loadSampleProducts() {
        products = [
            // Bonbons
            WorldProduct(name: "Mochi", 
                         country: "Japon", 
                         price: 5.99, 
                         description: "Délicieux mochi traditionnel", 
                         imageURL: "url_image_mochi", 
                         category: .candy, 
                         nutritionalInfo: WorldProduct.NutritionalInfo(
                            calories: 100, 
                            sugar: 15.5, 
                            allergens: ["Lait", "Soja"]
                         ), 
                         rating: 4.5),
            
            // Gâteaux
            WorldProduct(name: "Pastel de Nata", 
                         country: "Portugal", 
                         price: 3.50, 
                         description: "Célèbre tarte portugaise", 
                         imageURL: "url_image_pastel", 
                         category: .dessert, 
                         nutritionalInfo: WorldProduct.NutritionalInfo(
                            calories: 250, 
                            sugar: 20.0, 
                            allergens: ["Œufs", "Blé"]
                         ), 
                         rating: 4.8),
            
            // Boissons
            WorldProduct(name: "Bubble Tea", 
                         country: "Taiwan", 
                         price: 4.75, 
                         description: "Thé aux perles taiwanese", 
                         imageURL: "url_image_bubble_tea", 
                         category: .drink, 
                         nutritionalInfo: WorldProduct.NutritionalInfo(
                            calories: 280, 
                            sugar: 25.0, 
                            allergens: ["Lait"]
                         ), 
                         rating: 4.6)
        ]
    }
}

// Vue Principale
struct ContentView: View {
    var body: some View {
        TabView {
            WorldCatalogView()
                .tabItem {
                    Image(systemName: "globe")
                    Text("Catalogue Mondial")
                }
            
            // Autres onglets (Panier, Profil, etc.)
        }
    }
}
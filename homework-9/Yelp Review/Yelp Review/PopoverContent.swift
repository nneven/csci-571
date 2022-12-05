//
//  PopoverContent.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 12/5/22.
//

import SwiftUI

struct PopoverContent: View {
    @Binding var keyword: String
    @Binding var showPopover: Bool
    @State var results: [String] = []
    
    var body: some View {
        VStack {
            if (results.isEmpty) {
                let _ = autocomplete()
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 1)
                Text("loading...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.gray)
            } else {
                ForEach(results, id: \.self) { result in
                    Text(result)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                self.keyword = result
                                self.showPopover = false
                            }
                        }
                }
            }
        }
        .frame(height: 120)
        .padding()
    }
    
    func autocomplete() {
        var components = URLComponents(string: "https://csci-571-363723.wl.r.appspot.com/yelp")!
        let queryValue = "https://api.yelp.com/v3/autocomplete?text=" + keyword
        components.queryItems = [
            URLQueryItem(name: "url", value: queryValue)
        ]
        let url = URLRequest(url: components.url!)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print(response!)
                return
            }
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data)
                if let dict = json as? [String: Any] {
                    if let categoriesArray = dict["categories"] as? [Any] {
                        for category in categoriesArray {
                            if let categoryJson = category as? [String: Any] {
                                if let title = categoryJson["title"] as? String {
                                    results.append(title)
                                    // print(title)
                                }
                            }
                        }
                    }
                    if let termsArray = dict["terms"] as? [Any] {
                        for term in termsArray {
                            if let termJson = term as? [String: Any] {
                                if let text = termJson["text"] as? String {
                                    results.append(text)
                                    // print(text)
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
}

class ContentViewController<V>: UIHostingController<V>, UIPopoverPresentationControllerDelegate where V:View {
    var isPresented: Binding<Bool>
    
    init(rootView: V, isPresented: Binding<Bool>) {
        self.isPresented = isPresented
        super.init(rootView: rootView)
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = sizeThatFits(in: UIView.layoutFittingExpandedSize)
        preferredContentSize = size
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.isPresented.wrappedValue = false
    }
}

struct AlwaysPopoverModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    
    let isPresented: Binding<Bool>
    let contentBlock: () -> PopoverContent
    
    // Workaround for missing @StateObject in iOS 13.
    private struct Store {
        var anchorView = UIView()
    }
    @State private var store = Store()
    
    func body(content: Content) -> some View {
        if isPresented.wrappedValue {
            presentPopover()
        }
        
        return content
            .background(InternalAnchorView(uiView: store.anchorView))
    }
    
    private func presentPopover() {
        let contentController = ContentViewController(rootView: contentBlock(), isPresented: isPresented)
        contentController.modalPresentationStyle = .popover
        
        let view = store.anchorView
        guard let popover = contentController.popoverPresentationController else { return }
        popover.sourceView = view
        popover.sourceRect = view.bounds
        popover.delegate = contentController
        
        guard let sourceVC = view.closestVC() else { return }
        if let presentedVC = sourceVC.presentedViewController {
            presentedVC.dismiss(animated: true) {
                sourceVC.present(contentController, animated: true)
            }
        } else {
            sourceVC.present(contentController, animated: true)
        }
    }
    
    private struct InternalAnchorView: UIViewRepresentable {
        typealias UIViewType = UIView
        let uiView: UIView
        
        func makeUIView(context: Self.Context) -> Self.UIViewType {
            uiView
        }
        
        func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) { }
    }
}

extension View {
    public func alwaysPopover<Content>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        self.modifier(AlwaysPopoverModifier(isPresented: isPresented, contentBlock: content))
    }
}

extension UIView {
    func closestVC() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}

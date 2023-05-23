//
//  ViewController.swift
//  Project4
//
//  Created by Ning, Xinran on 22/5/23.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {  // Parent class first, then protocols

  // create web view
  var webView: WKWebView!
  var progressView: UIProgressView!

  // Our websites
  var websites = ["hackingwithswift.com", "youtube.com", "viki.com"]

  override func loadView() {
    webView = WKWebView()
    webView.navigationDelegate = self
    view = webView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
//    navigationController?.navigationBar.isOpaque = true
//    navigationItem.standardAppearance?.configureWithDefaultBackground()
//    navigationItem.scrollEdgeAppearance?.configureWithTransparentBackground()
//    navigationItem.standardAppearance?.configureWithOpaqueBackground()
//    navigationItem.scrollEdgeAppearance?.configureWithOpaqueBackground()

    let url = URL(string: "https://" + websites[0])!  // iOS requires https
    webView.load(URLRequest(url: url))
    webView.allowsBackForwardNavigationGestures = true
    title = "Welcome!"

    // Load open button
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))

    // Create toolbar
    progressView = UIProgressView(progressViewStyle: .default)
    progressView.sizeToFit()
    let progressButton = UIBarButtonItem(customView: progressView)
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))

    let back = UIBarButtonItem(title: "Back", style: .plain, target: webView, action: #selector(webView.goBack))
    let forward = UIBarButtonItem(title: "Forward", style: .plain, target: webView, action: #selector(webView.goForward))

    toolbarItems = [back, forward, progressButton, spacer, refresh]
    navigationController?.isToolbarHidden = false

    // Add ViewController as observer of webView
    webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
  }

  @objc func openTapped() {
    let ac = UIAlertController(title: "Open page:", message: nil, preferredStyle: .actionSheet)
    // add websites
    for website in websites {
      ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
    }
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem  // only for ipad
    present(ac, animated: true)
  }

  func openPage(action: UIAlertAction) {  // Since its a handler, it will take the alert as parameter
    let url = URL(string: "https://" + action.title!)!
    webView.load(URLRequest(url: url))

  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    title = webView.title
  }

  // method for observer
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "estimatedProgress" {
      progressView.progress = Float(webView.estimatedProgress)
    }
  }

  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    let url = navigationAction.request.url
    if let host = url?.host {  // host is the website domain, not all websites have them
      for website in websites {
        print("Host: \(host), Website: \(website), host.contains(website)?: \(host.contains(website))")
        if host.contains(website) {
          decisionHandler(.allow)
          return
        }
      }
    }
    decisionHandler(.cancel)
    let ac = UIAlertController(title: "Unsupported", message: "Sorry, this website is unsupported. Please go back.", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Go Back", style: .cancel))
    present(ac, animated: true)
  }


}


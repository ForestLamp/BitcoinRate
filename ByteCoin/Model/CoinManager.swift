//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation
import UIKit

protocol CoinManagerDelegate: AnyObject {
    func didUpdateCoin(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {

    private let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/"
    private let apiKey = "?apikey=36B40CDC-2BB8-44FB-B907-011F0EFDFA4F"
    
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func performRequest(for currency: String) {
        
        guard let url = URL(string: "\(baseURL)\(currency)\(apiKey)") else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, _, error in
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }
            if let safeData = data {
                if let bitcoinPrice = parseJSON(coinData: safeData) {
                    let priceString = String(format: "%.2f", bitcoinPrice)
                    delegate?.didUpdateCoin(price: priceString, currency: currency)
                }
            }
        }
        task.resume()
    }
    
    private func parseJSON(coinData: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodeData.rate
            return rate
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

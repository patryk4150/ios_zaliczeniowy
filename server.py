from flask import Flask

app = Flask(__name__)

data = """
[
  {
    "id": 1,
    "product": "iPhone 7",
    "description": "The iPhone 7 and 7 Plus are Apple's lower-cost iPhones, with camera improvements, a glossy black color, faster processors, and improved water resistance implemented through a click-less haptic home button and no headphone jack",
    "image": "https://image.ceneostatic.pl/data/products/47044601/i-apple-iphone-7-32gb-czarny.jpg",
    "location_lat": "50.0469018",
    "location_long": "19.8647883"     
  },
  {
    "id": 2,
    "product": "iPhone 8",
    "description": "The iPhone 8 features a 4.7-inch display with a resolution of 1334 by 750 with 326 pixels per inch and a 1400:1 contrast ratio, while the iPhone 8 Plus features a 5.5-inch display with a 1920 by 1080 resolution, 401 pixels per inch, and a 1300:1 contrast ratio.",
    "image": "https://image.ceneostatic.pl/data/products/55381561/i-apple-iphone-8-64gb-gwiezdna-szarosc.jpg",
    "location_lat": "52.2330269",
    "location_long": "20.7810087"       
  },
  {
    "id": 3,
    "product": "iPhone X",
    "description": "At a Glance. The iPhone X was Apple's flagship 10th anniversary iPhone featuring a 5.8-inch OLED display, facial recognition and 3D camera functionality, a glass body, and an A11 Bionic processor. Launched November 3, 2017, discontinued with the launch of the iPhone XR, XS, and XS Max",
    "image": "https://image.ceneostatic.pl/data/products/55424289/i-apple-iphone-x-64gb-srebrny.jpg",
    "location_lat": "54.3612063",
    "location_long": "18.5499432"       
  },
  {
    "id": 4,
    "product": "iPhone XR",
    "description": "The iPhone XR features a precision-machined 7000 Series aerospace-grade aluminum frame that wraps around an all-glass enclosure with the same durable glass used in the more expensive iPhone XS. Apple designed the iPhone XR in six colors: white, black, blue, coral, yellow, and (PRODUCT)RED",
    "image": "https://i4.skapiec.pl/1/77LktkraW1hZ2VzLzk3Y2ZkNTNlOWNhY2RiY2FjOGM1YmUyNWQxNDNmMThhLmpwZ5OVAs0CvADCw5UCAM0CvMLDkwmmZWFmYzk1Bg/apple-iphone-xr-64gb-czarny-mry42pm-a.jpg",
    "location_lat": "52.4006553",
    "location_long": "16.7615816"    
  }
]
"""

@app.route('/')
def index():
    response = app.response_class(
        response=data,
        status=200,
        mimetype='application/json'
    )
    return response

if __name__ == '__main__':
    app.run(debug=True)
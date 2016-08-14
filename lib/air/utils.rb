require 'uri'
require 'net/http'
require 'active_support/core_ext/hash'
require 'json'

class Station < ActiveRecord::Base
  belongs_to  :region
  has_many    :updates
end

class Region < ActiveRecord::Base
  has_many :stations
end

class Parameter < ActiveRecord::Base
  has_many :updates
end

class Update < ActiveRecord::Base
  belongs_to :parameter
  belongs_to :station
end

class Measurement < ActiveRecord::Base
  belongs_to  :parameter
  belongs_to  :station
end

module Air
  CONFIG = {
    language: "mk",

    site: {
      parameter:            "Параметар",
      parameterTitle:       "Загадувачка супстанца",
      station:              "Станица",
      stationTitle:         "Станица",
      endDate:              "Краен датум",	
      endDateTitle:         "До",
      timeMode:             "Временски период",
      timeModeTitle:        "Македонски",
      drawBackground:       "Исцртај позадина",
      drawBackgroundTitle:  "Македонски",
      graphSelector:        "График",	
      graphSelectorTitle:   "График",
      tableSelector:        "Табела",	
      tableSelectorTitle:   "Табела",
      hourName:             "Часовни",
      dayName:              "Дневно"
    },

    parameters: {
      CO: { name: "Јаглерод Моноксид (CO)" ,
            unit: "mg/m³", # &#179;	
            shortName: "CO",
            shortNameNoSubscript: "CO",
            levels: { # 8 hrs
              good:           Range.new(0, 1.00),
              moderate:       Range.new(1.001, 2.0),
              sensitive:      Range.new(2.001, 9.99),
              unhealthy:      Range.new(10.0, 16.99),
              very_unhealthy: Range.new(17.0, 33.99),
              hazardous:      Range.new(34.0, 100)
            }
          },
      NO2: { name: "Азот Диоксид (NO2)" ,
            unit: "µg/m³", # &#179;
            shortName: "NO₂", # &#8322;
            shortNameNoSubscript: "NO2",
            levels: { # 24 hrs
              good:           Range.new(0, 40.99),
              moderate:       Range.new(41.0, 80.99),
              sensitive:      Range.new(81.0, 180.99),
              unhealthy:      Range.new(181.0, 280.99),
              very_unhealthy: Range.new(281.0, 400.99),
              hazardous:      Range.new(401.0, 1000)
            }
          },
      O3: { name: "Озон (O3)",
            unit: "µg/m³", # &#179;
            shortName: "O₃", # &#8323;
            shortNameNoSubscript: "O3",
            levels: { # 8 hrs
              good:           Range.new(0, 50.99),
              moderate:       Range.new(51.0, 100.99),
              sensitive:      Range.new(101.0, 168.99),
              unhealthy:      Range.new(169.0, 208.99),
              very_unhealthy: Range.new(209.0, 748.99),
              hazardous:      Range.new(749.0, 2000)
            }
          },
      PM10: { name: "Суспендирани Честички (PM10)",
            unit: "µg/m³", # &#179;
            shortName: "PM₁₀", # &#8321;&#8320;
            shortNameNoSubscript: "PM10",
            levels: { # 24 hrs
              good:           Range.new(0, 50.99),
              moderate:       Range.new(51.0, 100.99),
              sensitive:      Range.new(101.0, 250.99),
              unhealthy:      Range.new(251.0, 350.99),
              very_unhealthy: Range.new(351.0, 430.99),
              hazardous:      Range.new(431.0, 2000)
            }
            },
      PM10D: { name: "Суспендирани Честички (PM10) Дневно",
            unit: "µg/m³", # &#179;
            shortName: "PM₁₀", # &#8321;&#8320;
            shortNameNoSubscript: "PM10D",
            levels: { # 24 hrs
              good:           Range.new(0, 50.99),
              moderate:       Range.new(51.0, 100.99),
              sensitive:      Range.new(101.0, 250.99),
              unhealthy:      Range.new(251.0, 350.99),
              very_unhealthy: Range.new(351.0, 430.99),
              hazardous:      Range.new(431.0, 2000)
            }
            },
      PM25: { name: "Суспендирани Честички (PM2.5)",
            unit: "µg/m³", # &#179;
            shortName: "PM₂.₅", # &#8322;.&#8325;
            shortNameNoSubscript: "PM2.5",
            levels: { # 24 hrs
              good:           Range.new(0, 30.99),
              moderate:       Range.new(31.0, 60.99),
              sensitive:      Range.new(61.0, 90.99),
              unhealthy:      Range.new(91.0, 120.99),
              very_unhealthy: Range.new(121.0, 250.99),
              hazardous:      Range.new(251.0, 2000)
            }
            },
      SO2:  { name: "Сулфур Диоксид (SO2)",
            unit: "µg/m³", # &#179;
            shortName: "SO₂", # &#8322;
            shortNameNoSubscript: "SO2",
            levels: { # 24 hrs
              good:           Range.new(0, 40.99),
              moderate:       Range.new(41.0, 80.99),
              sensitive:      Range.new(81.0, 380.99),
              unhealthy:      Range.new(381.0, 800.99),
              very_unhealthy: Range.new(801.0, 1600.99),
              hazardous:      Range.new(1601.0, 5000)
            }
            }
    },

    stations: {
      Centar:       { name: "Центар",       region: :SkopjeRegion },
      Karpos:       { name: "Карпош",       region: :SkopjeRegion },
      Lisice:       { name: "Лисиче",       region: :SkopjeRegion },
      GaziBaba:     { name: "Гази Баба",    region: :SkopjeRegion },
      Rektorat:     { name: "Ректорат",     region: :SkopjeRegion },
      Miladinovci:  { name: "Миладиновци",  region: :SkopjeRegion },
      Mrsevci:      { name: "Мршевци",      region: :SkopjeRegion },
      
      Bitola1:    { name: "Битола 1",   region: :WesternRegion },
      Bitola2:    { name: "Битола 2",   region: :WesternRegion },
      Kicevo:     { name: "Кичево",     region: :WesternRegion },
      Lazaropole: { name: "Лазарополе", region: :WesternRegion },
      Tetovo:     { name: "Тетово",     region: :WesternRegion },

      Veles1:     { name: "Велес 1",    region: :EasternRegion },
      Veles2:     { name: "Велес 2",    region: :EasternRegion },
      Kocani:     { name: "Кочани",     region: :EasternRegion },
      Kavadarci:  { name: "Кавадарци",  region: :EasternRegion },
      Kumanovo:   { name: "Куманово",   region: :EasternRegion },
      
      SkopjeRegion:   { name: "Агломерација Скопски pегион",  id: 0 },
      WesternRegion:  { name: "Западна зона",                 id: 1 },
      EasternRegion:  { name: "Источна зона",                 id: 2 }
    },

    timeModes: {
      Week: "Неделно",
      Day: "Дневно",
      Month: "Месечно"
    },	
      
    graph: {
      title: "Часовни концентрации за %s во %s"
    },

    daily_graph: {
    title: "Дневни %s концентрации за %s"
    },

    table: {
      title: "Часовни концентрации за %s"
    },
    metadata: {
      title: "Параметри на мерни станици"
    }
  }.with_indifferent_access.freeze

  
  YMD_FMT         = '%Y-%m-%d'
  MAKE_GRAPH_PATH = "http://airquality.moepp.gov.mk/graphs/site/pages/MakeGraph.php"
  METADATA_PATH   = "http://airquality.moepp.gov.mk/graphs/site/pages/Metadata.class.php"

  def self.get(opts = { })
    defaults = {
      station: 'GaziBaba',
      parameter: 'PM10',
      time_mode: 'Day',
      date: Date.today.strftime(YMD_FMT),
      draw_background: false,
      time: (Time.now.to_f * 1000).to_i,
      language: 'mk'
    }.with_indifferent_access
    opts = defaults.merge opts.with_indifferent_access
    opts.each {|k, v| puts "#{ k }: #{ v }" }
    url = MAKE_GRAPH_PATH +
          "?graph=StationLineGraph&station=#{ opts[:station] }" +
          "&parameter=#{ opts[:parameter] }&endDate=#{ opts[:date] }" +
          "&timeMode=#{ opts[:time_mode] }" +
          "&background=#{ opts[:draw_background] }" +
          "&i=#{ opts[:time] }&language=#{ opts[:language] }"

    uri = URI.parse url
    http = Net::HTTP.new uri.host, uri.port

    request = Net::HTTP::Get.new uri
    request['Accept'] = 'application/json'
    request['Cache-Control'] = 'no-cache'

    response = http.request request

    if response.code != '200'
      warn "received #{ response.code }"
      nil
    else
      (JSON.parse response.body).with_indifferent_access
    end
  end

  def self.update(opts = { })
    
    data = get opts
    h    = { }.with_indifferent_access

    param_id    = Parameter.find_by_name(opts[:parameter]).id
    station_id  = Station.find_by_name(opts[:station]).id


    update =  Update.find_by_parameter_id_and_station_id(param_id, station_id)

    data[:measurements].each do |dt, v|
      next if v[opts[:station]].nil? or v[opts[:station]].empty?      
      h[dt_fmt(dt)] = v[opts[:station]].to_f
    end
    
    count = h.keys.length
    if count == 0 # we don't save measurements, just update and return
      day        = Date.parse opts[:date]
      update.day = day
      update.save
      puts "No measurements for #{ opts[:date] }".colorize(:light_blue)
      return
    end

    # we have measurements 
    avg = h.values.inject(0) { |s, e| s + e } / count
    min = h.values.min
    max = h.values.max
    
    puts "min, max, avg: #{ min }, #{ max }, #{ avg }"
    puts "count: #{ count }"
    puts "parameter id: #{ param_id }, station id: #{ station_id }"
    puts "logs: #{ h.to_json }"

    Measurement.transaction do
      day        = Date.parse opts[:date]
      update.day = day
      update.save

      Measurement.create(day: day, parameter_id: param_id, station_id: station_id,
        count: count, min: min, max: max, avg: avg, data: h.to_json)
    end
  end
  
  def self.metadata(opts = { })
    defaults = {
      station: 'GaziBaba',
    }.with_indifferent_access
    opts    = defaults.merge opts.with_indifferent_access
    result  = { }.with_indifferent_access

    if opts[:station] == 'all'
      CONFIG[:stations].keys.each do |station|
        url   = METADATA_PATH + "?ajax=1&parametersForStation=#{ station }"
        uri   = URI.parse url
        http  = Net::HTTP.new uri.host, uri.port

        request = Net::HTTP::Get.new uri
        request['Accept'] = 'application/json'
        request['Cache-Control'] = 'no-cache'

        response = http.request request
        raise "received #{ response.code } for #{ station }" unless response.code == '200'
        result[station] =  if response.body == 'null'
                              [ ]
                            else
                              JSON.parse response.body 
                            end
      end
    else
      url   = METADATA_PATH + "?ajax=1&parametersForStation=#{ opts[:station] }"
      uri   = URI.parse url
      http  = Net::HTTP.new uri.host, uri.port

      request = Net::HTTP::Get.new uri
      request['Accept'] = 'application/json'
      request['Cache-Control'] = 'no-cache'

      response = http.request request

      result[opts[:station]] =  if response.body == 'null'
                                  [ ]
                                else
                                  JSON.parse response.body 
                                end
    end
    result
  end

  def self.dt_fmt(s)
    raise "Invalid date time #{ s }" unless s =~ /^\d{8} (0|1|2)\d$/
    sprintf "%s-%s-%s %s:00", s[0..3], s[4..5], s[6..7], s[9..10]
  end

  def self.level_color(parameter, value)
    value = value.to_f
    h = CONFIG[:parameters][parameter][:levels].select do |k, v|
      v.include? value
    end
    if h.empty?
      puts "#{ parameter } #{ value } not included?"
      return :magenta
    else
      return  case h.first[0].to_sym 
              when :good            then :green
              when :moderate        then :light_green
              when :sensitive       then :light_yellow
              when :unhealthy       then :yellow
              when :very_unhealthy  then :light_red
              when :hazardous       then :red
              else
                return :light_gray
              end
    end
  end

  START_DATE = {
    Centar: {
      CO:     Date.parse('2008-01-01'),
      NO2:    Date.parse('2012-09-09'),
      O3:     Date.parse('2011-09-09'),
      PM10:   Date.parse('2011-09-12'),
      PM25:   Date.parse('2011-09-10'),
      SO2:    Date.parse('2008-01-01')
    },
    Karpos: {
      CO:     Date.parse('2008-01-01'),
      NO2:    Date.parse('2011-09-10'),
      O3:     Date.parse('2011-09-09'),
      PM10:   Date.parse('2008-01-01'),
      PM25:   Date.parse('2011-09-10'),
      SO2:    Date.parse('2008-01-01')
    },
    Lisice: {
      CO:     Date.parse('2007-01-03'),
      NO2:    Date.parse('2011-03-02'),
      O3:     Date.parse('2008-01-01'),
      PM10:   Date.parse('2008-01-01'),
      PM25:   nil,
      SO2:    Date.parse('2007-01-03')
    },
    GaziBaba: {
      CO:     Date.parse('2007-01-01'),
      NO2:    Date.parse('2006-01-01'),
      O3:     nil,
      PM10:   Date.parse('2009-02-01'),
      PM25:   nil,
      SO2:    Date.parse('2007-01-05')
    },
    Rektorat: {
      CO:     Date.parse('2005-04-04'),
      NO2:    Date.parse('2005-04-04'),
      O3:     Date.parse('2005-04-04'),
      PM10:   Date.parse('2005-04-04'),
      PM25:   nil,
      SO2:    nil
    },
    Miladinovci: {
      CO:     Date.parse('2009-01-01'),
      NO2:    Date.parse('2006-01-01'),
      O3:     Date.parse('2008-01-01'),
      PM10:   Date.parse('2009-01-01'),
      PM25:   nil,
      SO2:    Date.parse('2009-01-01')
    },
    Mrsevci: {
      CO:     Date.parse('2004-08-07'),
      NO2:    Date.parse('2002-12-07'),
      O3:     nil,
      PM10:   Date.parse('2002-12-07'),
      PM25:   nil,
      SO2:    Date.parse('2002-12-07')
    },

    Bitola1: {
      CO:     Date.parse('2007-01-01'),
      NO2:    Date.parse('2011-11-12'),
      O3:     Date.parse('2008-01-01'),
      PM10:   Date.parse('2008-01-01'),
      PM25:   nil,
      SO2:    Date.parse('2007-01-01')
    },
    Bitola2: {
      CO:     Date.parse('2007-01-01'),
      NO2:    Date.parse('2011-12-26'),
      O3:     Date.parse('2008-01-01'),
      PM10:   Date.parse('2008-01-01'),
      PM25:   nil,
      SO2:    Date.parse('2007-01-01')
    },
    Kicevo: {
      CO:     Date.parse('2007-01-01'),
      NO2:    Date.parse('2011-05-31'),
      O3:     Date.parse('2008-01-01'),
      PM10:   Date.parse('2008-01-01'),
      PM25:   nil,
      SO2:    Date.parse('2007-01-01')
    },
    Lazaropole: {
      CO:     nil,
      NO2:    Date.parse('2012-01-05'),
      O3:     Date.parse('2008-01-01'),
      PM10:   Date.parse('2008-01-01'),
      PM25:   nil,
      SO2:    Date.parse('2007-01-01')
    },
    Tetovo: {
      CO:     Date.parse('2007-01-01'),
      NO2:    Date.parse('2009-12-31'),
      O3:     Date.parse('2008-01-01'),
      PM10:   Date.parse('2008-01-01'),
      PM25:   nil,
      SO2:    Date.parse('2007-01-01')
    },

    Veles1: {
      CO:     Date.parse('2007-01-01'),
      NO2:    Date.parse('2011-03-17'),
      O3:     Date.parse('2009-05-07'),
      PM10:   Date.parse('2009-04-15'),
      PM25:   nil,
      SO2:    Date.parse('2007-01-01')
    },
    Veles2: {
      CO:     Date.parse('2007-01-01'),
      NO2:    Date.parse('2012-01-01'),
      O3:     Date.parse('2008-01-01'),
      PM10:   Date.parse('2008-01-01'),
      PM25:   nil,
      SO2:    Date.parse('2007-01-23')
    },
    Kocani: {
      CO:     Date.parse('2002-10-29'),
      NO2:    Date.parse('2002-10-31'),
      O3:     Date.parse('2002-10-28'),
      PM10:   Date.parse('2002-10-31'),
      PM25:   nil,
      SO2:    Date.parse('2002-12-05')
    },
    Kavadarci: {
      CO:     Date.parse('2007-01-01'),
      NO2:    nil,
      O3:     Date.parse('2008-01-01'),
      PM10:   Date.parse('2008-01-01'),
      PM25:   nil,
      SO2:    Date.parse('2007-01-01')
    },
    Kumanovo: {
      CO:     Date.parse('2007-01-01'),
      NO2:    Date.parse('2012-01-01'),
      O3:     Date.parse('2008-01-01'),
      PM10:   Date.parse('2007-01-01'),
      PM25:   nil,
      SO2:    Date.parse('2008-01-01')
    },
  }.with_indifferent_access
end # Module Air

__END__

2007-01-01
2012-01-01
2008-01-01
2007-01-01
NA
2008-01-01

NOTE: this is a copy. The actual data is in air main ruby file

Station           CO        NO2          O3        PM10        PM25         SO2
----------- ----------- ----------- ----------- ----------- ----------- -----------
Centar      *2008-01-01 *2011-09-09 *2011-09-09 !2011-09-12 *2011-09-10 *2008-01-01
Karpos      *2008-01-01 *2011-09-10 *2011-09-09  2008-01-01 *2011-09-10 *2008-01-01
Lisice      *2007-01-03 *2011-03-02 *2008-01-01  2008-01-01     NA      *2007-01-03
GaziBaba    *2007-01-01 *2006-01-01      NA      2009-02-01     NA      *2007-01-05
Rektorat    *2005-04-04 *2005-04-04 *2005-04-04 *2005-04-04     NA          NA
Miladinovci *2009-01-01 *2006-01-01 *2008-01-01 *2009-01-01     NA      *2009-01-01
Mrsevci     *2004-08-07 *2002-12-07      NA     *2002-12-07     NA      *2002-12-07

Bitola1     *2007-01-01 *2011-11-12 *2008-01-01 *2008-01-01     NA      *2007-01-01
Bitola2     *2007-01-01 *2011-12-26 *2008-01-01 *2008-01-01     NA      *2007-01-01 
Kicevo      *2007-01-01 *2011-05-31 *2008-01-01 *2008-01-01     NA      *2007-01-01
Lazaropole        NA    *2012-01-05 *2008-01-01 *2008-01-01     NA      *2007-01-01
Tetovo      *2007-01-01 *2009-12-31 *2008-01-01 *2008-01-01     NA      *2007-01-01

Veles1      *2007-01-01 *2011-03-17 *2009-05-07 *2009-04-15     NA      *2007-01-01
Veles2      *2007-01-01 *2012-01-01 *2008-01-01 ?2008-01-01     NA      *2007-01-23
Kocani      *2002-10-29 *2002-10-31 *2002-10-28 *2002-10-31     NA      *2002-12-05
Kavadarci   *2007-01-01    ?NA      *2008-01-01 ?2008-01-01     NA      *2007-01-01
Kumanovo    *2007-01-01  2012-01-01 *2008-01-01 ?2007-01-01     NA      *2008-01-01


! = 2011-09-10 zero measurements
* = definite start
? = not checked completelly

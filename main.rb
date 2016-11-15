#!mruby
debug = Serial.new(0, 115200)
gps = Serial.new(1, 9600)

Ssd1306.begin(0x3C)
Ssd1306.set_text_wrap(false)
Ssd1306.set_text_size(1)
Ssd1306.clear_display
Ssd1306.display


debug.println("start")

sw = 0
buf = ""

loop do
    while (gps.available > 0) do
        c = gps.read
        buf = buf + c
    end
    
    lines = buf.to_s.split("\r\n")
    lines.each do |line|
        line = line.chomp
        
        messages = line.split(',')
        if messages[0] == '$GPVTG' and messages.length == 10
            debug.println("#{sw}: #{messages[7]}km/h")
            sw = 1 - sw
            led sw
            
            Ssd1306.clear_display
            Ssd1306.set_text_size(1)
            if messages[9][0] == 'N'
                Ssd1306.draw_text(0, 62, "NONE") if messages[9][0] == 'N'
                Ssd1306.set_text_size(2)
                Ssd1306.draw_text(0, 36, "-.--km/h")
            else
                Ssd1306.draw_text(0, 62, "Autonomous") if messages[9][0] == 'A'
                Ssd1306.draw_text(0, 62, "Differential") if messages[9][0] == 'D'
                Ssd1306.draw_text(0, 62, "Estimated") if messages[9][0] == 'E'
                Ssd1306.set_text_size(2)
                Ssd1306.draw_text(0, 36, "#{messages[7]}km/h")
            end
            Ssd1306.display
        end
        
        # buf = line
        buf = ""
    end

    delay 10

end


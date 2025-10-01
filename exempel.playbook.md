Bra tanke! Att visa att du kan hantera både enkla filer OCH arkiv visar verkligen att du förstår olika scenarios. Här är ett bra sätt att göra det:

Alternativ 1: Hybrid approach (rekommenderad för att imponera)
---
# Ping test for all servers
- name: Test connectivity to all servers
  hosts: all
  tasks:
    - name: Ping all servers
      ping:
        data: "Assignment 1 connectivity test"
      register: ping_result
    - name: Show ping results
      debug:
        msg: "{{ inventory_hostname }}: {{ ping_result.ping }}"

# Configure webservers with Apache
- name: Install and configure Apache webservers
  hosts: webservers
  become: yes
  tasks:
    - name: Update package cache
      apt:
        update_cache: yes

    - name: Install Apache2
      apt:
        name: apache2
        state: latest

    # Option 1: Copy single file (current approach)
    - name: Copy main index.html to webservers
      copy:
        src: ./index.html
        dest: /var/www/html/index.html
        owner: www-data
        group: www-data
        mode: '0644'

    # Option 2: Unarchive additional web assets (shows you know both methods)
    - name: Deploy additional web assets from archive
      unarchive:
        src: ./files/web-assets.tar.gz
        dest: /var/www/html/
        owner: www-data
        group: www-data
        creates: /var/www/html/assets/style.css
      ignore_errors: yes  # In case the tar.gz doesn't exist yet

    - name: Customize index.html with hostname
      ansible.builtin.shell: |
        echo "<h1>Webserver: $(hostname)</h1>" > /var/www/html/hostname-info.html
        echo "<p>Content delivered by $(hostname)</p>" >> /var/www/html/hostname-info.html
        if [ -f /var/www/html/index.html ]; then
          cat /var/www/html/hostname-info.html >> /var/www/html/index.html
        else
          cp /var/www/html/hostname-info.html /var/www/html/index.html
        fi

    - name: Configure Apache to listen on port 80
      ansible.builtin.lineinfile:
        path: /etc/apache2/ports.conf
        regexp: '^Listen '
        line: 'Listen {{ webserver_port }}'
      notify: restart-apache

    - name: Ensure Apache is running and enabled
      service:
        name: apache2
        state: started
        enabled: yes

  handlers:
    - name: restart-apache
      service:
        name: apache2
        state: restarted

# Configure load balancer with Nginx
- name: Install and configure Nginx load balancer
  hosts: loadbalancer
  become: yes
  tasks:
    - name: Update package cache
      apt:
        update_cache: yes

    - name: Install Nginx
      apt:
        name: nginx
        state: latest

    - name: Create nginx load balancer configuration
      template:
        src: nginx-loadbalancer.conf.j2
        dest: /etc/nginx/sites-available/loadbalancer
      notify: restart-nginx

    - name: Remove default nginx site
      file:
        path: /etc/nginx/sites-enabled/default
        state: absent
      notify: restart-nginx

    - name: Enable load balancer configuration
      file:
        src: /etc/nginx/sites-available/loadbalancer
        dest: /etc/nginx/sites-enabled/loadbalancer
        state: link
      notify: restart-nginx

    - name: Ensure Nginx is running and enabled
      service:
        name: nginx
        state: started
        enabled: yes

  handlers:
    - name: restart-nginx
      service:
        name: nginx
        state: restarted



Skapa en mappstruktur som imponerar:
# Skapa files mapp
mkdir -p files/web-assets

# Skapa några extra filer för att visa kunskap
echo "body { background: #f0f0f0; }" > files/web-assets/style.css
echo "console.log('Webserver ready!');" > files/web-assets/script.js
echo "<h2>Extra content from archive</h2>" > files/web-assets/extra.html

# Skapa tar.gz arkiv
cd files
tar -czf web-assets.tar.gz web-assets/
cd ..


Fördelar med denna approach:
✅ Visar båda metoderna - copy OCH unarchive
✅ Praktiskt - Huvudfilen (index.html) kopieras direkt
✅ Skalbart - Extra assets från arkiv
✅ Professionellt - Visar att du förstår olika scenarios
✅ Felsäkert - ignore_errors: yes om arkivet inte finns

När du förklarar för läraren:
"Jag använde copy för huvudfilen eftersom det är enklare, men också unarchive för att visa att jag kan hantera flera filer och komprimering - användbart när man har CSS, JavaScript, bilder etc."

Denna approach visar att du tänker som en professionell utvecklare! 🎯


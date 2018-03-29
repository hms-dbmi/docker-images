import org.transmart.searchapp.AuthUser
import org.transmart.searchapp.Requestmap
import org.transmart.searchapp.Role

grails {
	plugin {
		springsecurity {
			auth0 {
				clientId = "${System.getenv("AUTH0_CLIENT_ID")}"
				clientSecret = "${System.getenv("AUTH0_CLIENT_SECRET")}"
				domain = "${System.getenv("AUTH0_DOMAIN")}"
				useRecaptcha = false
				webtaskBaseUrl = "${System.getenv("AUTH0_WEBTASK_URL")}"
			}
			apf.storeLastUsername = true
			authority.className = Role.name
			controllerAnnotations.staticRules = [
				'/**':                          'IS_AUTHENTICATED_REMEMBERED',
				'/accessLog/**':                'ROLE_ADMIN',
				'/analysis/getGenePatternFile': 'permitAll',
				'/analysis/getTestFile':        'permitAll',
				'/authUser/**':                 'ROLE_ADMIN',
				'/authUserSecureAccess/**':     'ROLE_ADMIN',
				'/css/**':                      'permitAll',
				'/images/**':                   'permitAll',
				'/js/**':                       'permitAll',
				'/login/**':                    'permitAll',
				'/requestmap/**':               'ROLE_ADMIN',
				'/role/**':                     'ROLE_ADMIN',
				'/search/loadAJAX**':           'permitAll',
				'/secureObject/**':             'ROLE_ADMIN',
				'/secureObjectAccess/**':       'ROLE_ADMIN',
				'/secureObjectPath/**':         'ROLE_ADMIN',
				'/userGroup/**':                'ROLE_ADMIN',
				'/auth0/**':                    'permitAll',
				'/registration/**':             'permitAll',
				'/console/**': 'permitAll'
			]
			rejectIfNoRule = false // revert to old behavior
			fii.rejectPublicInvocations = false // revert to old behavior
			logout.afterLogoutUrl = '/'
			requestMap.className = Requestmap.name
			// securityConfigType = 'Requestmap'
			successHandler.defaultTargetUrl = '/userLanding'
			userLookup {
				authorityJoinClassName = AuthUser.name
				passwordPropertyName = 'passwd'
				userDomainClassName = AuthUser.name
			}
		}
	}
}


edu.harvard.transmart.email.notify = "${System.getenv("NOTIFICATION_EMAILS")}"
edu.harvard.transmart.email.logo = '/images/info_security_logo_rgb.png'
com.recomdata.searchtool.largeLogo = 'transmartlogoHMS.jpg'
com.recomdata.searchtool.appTitle = 'Department of Biomedical Informatics – tranSMART'

grails.logging.jul.usebridge = true

log4j = {
	appenders {
		rollingFile name: 'file', maxFileSize: 1024 * 1024, file: 'app.log'
		rollingFile name: 'sql',  maxFileSize: 1024 * 1024, file: 'sql.log'
	}

	error 'org.codehaus.groovy.grails',
	      'org.springframework',
	      'org.hibernate',
	      'net.sf.ehcache.hibernate'
	debug sql: 'org.hibernate.SQL', additivity: false
   debug sql: 'groovy.sql.Sql', additivity: false
	// trace sql: 'org.hibernate.type.descriptor.sql.BasicBinder', additivity: false

	root {
		warn 'file'
	}
}

grails {
	mail {
		host = 'smtp.gmail.com'
		port = 587
		username = "${System.getenv("EMAIL_USER")}"
		password = "${System.getenv("EMAIL_PASS")}"
		props = ['mail.smtp.auth': 'true',
		         'mail.smtp.socketFactory.port': '587',
		         'mail.smtp.socketFactory.class': 'javax.net.ssl.SSLSocketFactory',
		         'mail.smtp.socketFactory.fallback': 'false']
	}
}

fractalis {
	// Must be a PIC-SURE endpoint unless i2b2-tranSMART supports additional data APIs.
	dataSource = "${System.getenv("FRACTALIS_DATA_SOURCE")}"
	// Must be a resource name that 'fractalis.dataSource' has access to. E.g. '/nhanes/Demo'
	resourceName = "${System.getenv("FRACTALIS_RESOURCE_NAME")}"
	// Must be a Fractalis endpoint. See https://git-r3lab.uni.lu/Fractalis for further information.
	node = "${System.getenv("FRACTALIS_NODE")}"
}

org.transmart.configFine = true

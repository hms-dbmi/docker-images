import org.transmart.searchapp.AuthUser
import org.transmart.searchapp.Requestmap
import org.transmart.searchapp.Role

grails {
	plugin {
		springsecurity {

			/* {{{ Auth0 configuration */
			auth0 {
				active = "${System.getenv("AUTH0_ACTIVE")}" ? true : false
				clientId = "${System.getenv("CLIENT_ID")}"
				clientSecret = "${System.getenv("CLIENT_SECRET")}"
				domain = "${System.getenv("AUTH0_DOMAIN")}"
				useRecaptcha = false
				webtaskBaseUrl = "${System.getenv("AUTH0_WEBTASK_URL")}"
			}
			/* }}} */

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

/* {{{ UI Configuration */
com.recomdata.searchtool.largeLogo = 'transmartlogoHMS.jpg'
com.recomdata.searchtool.appTitle = 'Department of Biomedical Informatics – tranSMART'
/* }}} */


/* {{{ Logging Configuration */
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
/* }}} */


/* {{{ Faceted Search Configuration */
/* {{{ File store and indexing configuration */
com.rwg.solr.scheme = 'http'
com.rwg.solr.host   = 'solr:' + 8983
com.rwg.solr.path   = '/solr/rwg/select/'
com.rwg.solr.browse.path   = '/solr/browse/select/'
com.rwg.solr.update.path = '/solr/browse/dataimport/'
com.recomdata.solr.baseURL = "${com.rwg.solr.scheme}://${com.rwg.solr.host}" +
                            "${new File(com.rwg.solr.browse.path).parent}"

com {
	recomdata {
		solr {
			maxNewsStories = 10
			maxRows = 10000
		}
	}
}
/* }}} */

/* {{{ Sample Explorer configuration */

// This is an object to dictate the names and 'pretty names' of the SOLR fields.
// Optionally you can set the width of each of the columns when rendered

// TODO: this is configured twice in transmart-data:release-16.2. Is it a bug? -Andre
sampleExplorer {
    fieldMapping = [
        columns:[
            [header:'ID', dataIndex:'id', mainTerm: true, showInGrid: true, width:20],
            [header:'trial name', dataIndex:'trial_name', mainTerm: true, showInGrid: true, width:20],
            [header:'barcode', dataIndex:'barcode', mainTerm: true, showInGrid: true, width:20],
            [header:'plate id', dataIndex:'plate_id', mainTerm: true, showInGrid: true, width:20],
            [header:'patient id', dataIndex:'patient_id', mainTerm: true, showInGrid: true, width:20],
            [header:'external id', dataIndex:'external_id', mainTerm: true, showInGrid: true, width:20],
            [header:'aliquot id', dataIndex:'aliquot_id', mainTerm: true, showInGrid: true, width:20],
            [header:'visit', dataIndex:'visit', mainTerm: true, showInGrid: true, width:20],
            [header:'sample type', dataIndex:'sample_type', mainTerm: true, showInGrid: true, width:20],
            [header:'description', dataIndex:'description', mainTerm: true, showInGrid: true, width:20],
            [header:'comment', dataIndex:'comment', mainTerm: true, showInGrid: true, width:20],
            [header:'location', dataIndex:'location', mainTerm: true, showInGrid: true, width:20],
            [header:'organism', dataIndex:'source_organism', mainTerm: true, showInGrid: true, width:20],
			// consolidated the sampleExplorer field mapping. is this a bug? -Andre
			[header:'Sample ID',dataIndex:'id', mainTerm: false, showInGrid: false],
			[header:'BioBank', dataIndex:'BioBank', mainTerm: true, showInGrid: true, width:10],
			[header:'Source Organism', dataIndex:'Source_Organism', mainTerm: true, showInGrid: true, width:10]
			// Continue as you have fields

		]
    ]
    resultsGridHeight = 100
    resultsGridWidth = 100
    idfield = 'id'
}

// TODO: this is configured twice in transmart-data:release-16.2. Is it a bug? -Andre
edu.harvard.transmart.sampleBreakdownMap = [
    "aliquot_id":"Aliquots in Cohort",
	"id":"Aliquots in Cohort"

]
/* }}} */


/* {{{ Rserve configuration */
// This is to target a remove Rserve. Bear in mind the need for shared network storage
def jobsDirectory     = "/var/tmp/jobs/"

RModules.host = "rserve"
RModules.port = 6311

// This is not used in recent versions; the URL is always /analysisFiles/
RModules.imageURL = "/tempImages/" //must end and start with /

production {
    // The working directory for R scripts, where the jobs get created and
    // output files get generated
    RModules.tempFolderDirectory = jobsDirectory
}
development {
    RModules.tempFolderDirectory = "/tmp"

    /* we don't need to specify temporaryImageDirectory, because we're not copying */
}

// Used to access R jobs parent directory outside RModules (e.g. data export)
com.recomdata.plugins.tempFolderDirectory = RModules.tempFolderDirectory
/* }}} */


/* {{{ Email notification configuration */
edu.harvard.transmart.email.notify = "${System.getenv("NOTIFICATION_EMAILS")}"
edu.harvard.transmart.email.logo = '/images/info_security_logo_rgb.png'

grails {
	mail {
		host = 'smtp.gmail.com'
		// was 587. temporary - Andre
		port = 465
		username = "${System.getenv("EMAIL_USER")}"
		password = "${System.getenv("EMAIL_PASS")}"
		props = ['mail.smtp.auth': 'true',
				// was 587. temproary - Andre
		         'mail.smtp.socketFactory.port': '465',
		         'mail.smtp.socketFactory.class': 'javax.net.ssl.SSLSocketFactory',
		         'mail.smtp.socketFactory.fallback': 'false']
	}
}
/* }}} */


/* {{{ Fractalis configuration */
fractalis {
	active = "${System.getenv("FRACTALIS_ACTIVE")}" ? true: false
	// Must be a PIC-SURE endpoint unless i2b2-tranSMART supports additional data APIs.
	dataSource = "${System.getenv("FRACTALIS_DATA_SOURCE")}"
	// Must be a resource name that 'fractalis.dataSource' has access to. E.g. '/nhanes/Demo'
	resourceName = "${System.getenv("FRACTALIS_RESOURCE_NAME")}"
	// Must be a Fractalis endpoint. See https://git-r3lab.uni.lu/Fractalis for further information.
	node = "${System.getenv("FRACTALIS_NODE")}"
}
/* }}} */

org.transmart.configFine = true

TerminatOOOR - Brute Force your OpenERP data integration with [OOOR](http://github.com/rvalyi/ooor) inside the [Kettle](http://www.pentaho.com/products/demos/PDI_overview/PDI_overview.html) ETL
====

<table>
    <tr>
        <td><b>BY</b></td>
        <td><a href="http://www.akretion.com" title="Akretion - open source to spin the world"><img src="https://assets2.github.com/img/bab7caac292ea1315f458744409ad69f05409ef2?repo=&url=http://akretion.s3.amazonaws.com/assets/logo.png&path=" width="320px" height="154px" /></a></td>
        <td>
A JRuby JSR223 intergation of the OOOR OpenERP connector inside the Kettle ETL
        </td>
    </tr>
</table>


Why?
------------

[OpenERP](http://openerp.com/) is all the rage among open source ERP's but its native import/export have limitations when it comes to data integration. Server side OpenERP import/export is powerful but not so easy to get started and get interfaced. On the contrary, the famous [Kettle](http://www.pentaho.com/products/demos/PDI_overview/PDI_overview.html) open source [ETL](http://en.wikipedia.org/wiki/Extract,_transform,_load) from Pentaho connects to almost anything, any SGBD thanks to the JDBC connectors, any CSV, Excell files...

With TerminatOOOR you have all the power of the full OpenERP API right inside your ETL data in/out flow. You can do any Create Read Update Delete operation enforcing the access rights of OpenERP. But you are absolutely not imited to that, in fact you can just do anything you would do with your OpenERP client: click buttons, perform workflow actions, trigger on_change events... This is because [OOOR](http://github.com/rvalyi/ooor) gives you the full access to OpenERP API.


How?
------------

We are here leveraging futuristic technology: we run the [OOOR](http://github.com/rvalyi/ooor) OpenERP connector inside Kettle using JRuby and the [JSR223](http://java.sun.com/developer/technicalArticles/J2SE/Desktop/scripting/).


Using it
------------


IMPORTANT NOTICE
------------

THE FOLLOWING AFTER THIS SECTION DOCUMENTATION HAS BEEN LARGELY DEPRECATED BY THE TERMINATOOOR AUTHORS THEMSELVES.
Yeah this was for the bad news.
But on the good news side, we promiss you that you won't regret the first TerminatOOOR versions as the new technology is just even a lot better.

We will update the documentation about the 'new way' to use TerminatOOOR.
But in short, from TerminatOOOR2 and above, you should actually:

1) get the fantastic "Ruby Scripting for Kettle" by Slawomir Chodnicki http://type-exit.org/adventures-with-open-source-bi/kettle-plugins/ruby-scripting-plugin/
2) learn that great plugin using the provided Samples and learning the basics of Ruby (like 4 hours not more)
2) get the OOOR gem and dependencies installed in the gem directory of that plugin. This can easily be done by downloading the last TerminatOOOR zip here or using the great kettle_connector extra addons for OpenERP that comes with an installer that will wire all pieces together for you automatically.
3) Enjoy!
4) Learn how to dominate all the kettle_connector trick for a fast an seamless OpenERP and Kettle integration.

Doc coming, sorry for the delay guys, we are making our very best.



First you better learn a bit about [Kettle](http://kettle.pentaho.org/) (also see démos of [the Kettle ETL](http://www.pentaho.com/products/demos/PDI_overview/PDI_overview.html) and its [AgileBIT plugin](http://www.osbi.fr/?p=1045)) and [OOOR](http://github.com/rvalyi/ooor).
Installation:

*  Watch a demo: [http://www.youtube.com/watch?v=gH4AN5p9YKI&fmt=22](http://www.youtube.com/watch?v=gH4AN5p9YKI&fmt=22)
*  Download Kettle 4 for instance from [here](http://ci.pentaho.com/view/Data%20Integration/job/Kettle/lastSuccessfulBuild/artifact/Kettle/)
*  download the [terminatoor.zip](http://github.com/rvalyi/terminatooor/downloads) file or from source using GIT
*  copy the jruby-ooor.jar file inside the Kettle libext directory (a classpath trouble with JSR223 and multiple classloaders force us to do that trick)
*  copy the terminatooor directory in Kettle plugins/steps/terminatooor
*  start Kettle, this can be done with the sh spoon.sh command inside your Kettle directory on Linux for instance
*  drag and drop the "TerminatOOOR" transfo from the transfo design panel listing the available plugins/transfos
*  learn how to use the TerminatOOOR step: you'll have to enter simple Ruby scripts and also instanciate OOOR connectors properly
*  there is a work in progress comprehensive documentation beeing written [here](http://docs.google.com/View?docID=0ASvZhKivgdfZZGY5am4yNWJfNDJocmZ2NXNmZg&revision=_latest)


*  hint #1: usually we avoid instanciating an OOOR connector for each Kettle line, so we create a second tab (right click on the top of the current tab) and add a second tab. With an other right click, we set that second script as a "StartScript" that
will be executed only once. This is where we will instanciate an OOOR connector (this is required in each TerminatOOOR step). Then inside the main script running for each line, we can use OOOR models as we want.
*  hint #2: for extracting OpenERP resources, a good approach is to make a first search inside a first TerminatOOOR that run only once cause he his connected to a "RowGenerator" of only 1 row. Then we stores those ids in a String properly. Finally,
we use a split transformation to transform that list of ids as a String into several Kettle lines: this allows us to read each resource individually in a last TerminatOOOR step!
*  hint #3: learn the two read and write [included samples](http://github.com/rvalyi/terminatooor/tree/master/terminatooor/samples/)



Gotchas
------------

- Beware of Ruby variable names! In Ruby variables cannot be uppercase and cannot have spaces. So if you have such columns names in some Excell/CSV file you want to import,
you might want to use the "Select Values" Transform step to re-map the columns before entering the "TerminatOOOR" step.
- Doing loops in Kettle is not so easy, think rather about collecting variables in global Ruby variables, splitting columns values, or read that Kettle documentation [link 1](http://type-exit.org/adventures-with-open-source-bi/2010/11/dealing-with-comma-separated-fields-in-kettle/) or [link 2](http://www.osbi.fr/?p=1736); also look at the samples bundled with TerminatOOOR.
- It only works with Kettle 4. This is because we wanted to let a chance to Pentaho to refactor in the next version their scripting transfo to support the JSR223 and all Java backed languages, not just Rhino Javascript. All busy they are integrating with SAP or Salesforce, not sure they are smart enough tto figure out how important that is, but in any case we gave them the oppportunity, see our [JRipple patch version of their scripting step](http://github.com/rvalyi/jripple)
- You should put the jruby-ooor jar (JRuby + basic gems + last OOOR gem bundled) inside your Kettle libext directory otherwise, for strange reasons, the JRuby interpreter will not be found (sounds like a classloader issue).
- If you get an error such as "Too many open files" after doing a lot of OpenERP request (large synchro), then it's because for some strange reason the JRuby XML/RPC client will open a lot of sockets, at least when used within the JSR223 (not sure if that's a bug, but that's really challenging to find out). You could see that using the lsof command on Linux. An effective workaround is to enable more sockets in your OS settings. On Linux, you can edit the /etc/security/limits.conf files and just before the last line, you write: "* - nofile 65535" without quotes. Then restart the PC. After that, should have no "too many open files" issues anymore.

TerminatOOOR - Brute Force your OpenERP data integration with [OOOR](http://github.com/rvalyi/ooor) inside the [Kettle](http://www.pentaho.com/products/demos/PDI_overview/PDI_overview.html) ETL
====

<table>
    <tr>
        <td><b>BY</b></td>
        <td><a href="http://www.akretion.com" title="Akretion - open source to spin the world"><img src="http://sites.google.com/site/assetserversite/_/rsrc/1257126470309/home/akretion_s.png" width="228px" height="124px" /></a></td>
        <td>
A JRuby JSR223 intergation of the [OOOR](http://github.com/rvalyi/ooor) [OpenERP](http://openerp.com/) connector inside the  [Kettle](http://www.pentaho.com/products/demos/PDI_overview/PDI_overview.html) ETL
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

To be done. You can learn [Kettle](http://kettle.pentaho.org/) and [OOOR](http://github.com/rvalyi/ooor) meanwhile.


Gotchas
------------

- It only works with Kettle 4 (development version so far). Grab one of the latest version [here](http://ci.pentaho.com/view/Data%20Integration/job/Kettle/). This is because we wanted to let a chance to Pentaho to refactor in the next version their scripting transfo to support the JSR223 and all Java backed languages, not just Rhino Javascript. All busy they are integrating with SAP or Salesforce, not sure they are smart enough tto figure out how important that is, but in any case we gave them the oppportunity, see our [JRipple patch version of their scripting step](http://github.com/rvalyi/jripple)
- You should put the jruby-complete-ooor jar (JRuby + basic gems + last OOOR gem bundled) inside your Kettle libext directory otherwise, for strange reasons, the JRuby interpreter will not be found (sounds like a classloader issue).
- If you get an error such as "Too many open files" after doing a lot of OpenERP request (large synchro), then it's because for some strange reason the JRuby XML/RPC client will open a lot of sockets, at least when used within the JSR223 (not sure if that's a bug, but that's really challenging to find out). You could see that using the lsof command on Linux. An effective workaround is to enable more sockets in your OS settings. On Linux, you can edit the /etc/security/limits.conf files and just before the last line, you write: "* - nofile 65535" without quotes. Then restart the PC. After that, should have no "too many open files" issues anymore.
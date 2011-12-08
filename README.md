TerminatOOOR - Brute Force your OpenERP data integration with [OOOR](http://github.com/rvalyi/ooor) inside the [Kettle](http://www.pentaho.com/products/demos/PDI_overview/PDI_overview.html) ETL
====

<table>
    <tr>
        <td><b>BY</b></td>
        <td><a href="http://www.akretion.com" title="Akretion - open source to spin the world"><img src="https://assets2.github.com/img/bab7caac292ea1315f458744409ad69f05409ef2?repo=&url=http://akretion.s3.amazonaws.com/assets/logo.png&path=" width="320px" height="154px" /></a></td>
        <td>
A JRuby integration of the OOOR OpenERP connector inside the Kettle ETL
        </td>
    </tr>
</table>

<img src="http://akretion.s3.amazonaws.com/assets/TerminatOOOR.png" width="600px" height="495px" />

Why?
------------

[OpenERP](http://openerp.com/) is all the rage among open source ERP's but its native import/export have limitations when it comes to data integration. Server side OpenERP import/export is powerful but not so easy to get started and get interfaced. On the contrary, the famous [Kettle](http://www.pentaho.com/products/demos/PDI_overview/PDI_overview.html) open source [ETL](http://en.wikipedia.org/wiki/Extract,_transform,_load) from Pentaho connects to almost anything, any SGBD thanks to the JDBC connectors, any CSV, Excell files...

With TerminatOOOR you have all the power of the full OpenERP API right inside your ETL data in/out flow. You can do any Create Read Update Delete operation enforcing the access rights of OpenERP. But you are absolutely not imited to that, in fact you can just do anything you would do with your OpenERP client: click buttons, perform workflow actions, trigger on_change events... This is because [OOOR](http://github.com/rvalyi/ooor) gives you the full access to OpenERP API.


How?
------------

Until recently we have been forking the original Mozilla Rhino Javascript plugin for Kettle to support many JVM languages through the JSR-223 specificaion. Of course the language of interrest was JRuby, which was allowing us to run the OOOR OpenERP Ruby
connector right inside the ETL data flow.

Those were the early epic days of the TerminatOOOR technology. We never have been proud of the initial legacy code inherited here from the original Kettle Rhino plugin but the thing is: it was working as you can see on [this old 2010
screencast](http://www.youtube.com/watch?v=gH4AN5p9YKI). But this was without counting on the excellent
work from Slawomir Chodnicki who had the courage to re-start a full clean JRuby connector for Kettle. In order to benefit from the extended power of JRuby, Slawomir used the "RedBridge" Java integration framework instead of the JSR-223, which means
we have extra capabilities but won't run other JVM langages such as Jython. You could still see that old version in the old branch.

As soon as Slawomir proposed his [Ruby-Scripting-for-Kettle](https://github.com/type-exit/Ruby-Scripting-for-Kettle) plugin, we started using it along with the OOOR gem. But the drawback is that average users wouldn't be able to go through all the
installation steps and we would miss a large part of our audience. This is the reason why we decided to re-package Slawomir plugin here directly with the proper gems like OOOR and JOOOR direcly bundled in.


Using it
------------

You should read the [complete documentation](https://docs.google.com/a/akretion.com.br/document/d/1KaHO2LlNpqhv7X3jqWlbDrUZEqD5JtK8D5yyCqUtR90/edit?hl=en_US&pli=1)
